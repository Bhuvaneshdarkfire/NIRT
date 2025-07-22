import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  _ApplyLeaveScreenState createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final reason = TextEditingController();
  String selectedType = 'Casual Leave';
  DateTime? fromDate;
  DateTime? toDate;
  bool isSubmitting = false;

  Future<void> _pickDate(BuildContext context, bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  Future<void> submitLeaveRequest() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    if (fromDate == null || toDate == null || reason.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select dates")),
      );
      return;
    }

    if (toDate!.isBefore(fromDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("To Date cannot be before From Date")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // 🔁 Fetch user info from 'employees' collection using phone auth
      final userDoc = await FirebaseFirestore.instance.collection('employees').doc(uid).get();
      final userData = userDoc.data();

      final userName = userData?['name'] ?? 'Unknown';
      final userPhone = userData?['phone'] ?? 'N/A';

      await FirebaseFirestore.instance.collection('leaves').add({
        'uid': uid,
        'name': userName,
        'phone': userPhone,
        'type': selectedType,
        'reason': reason.text.trim(),
        'status': 'pending',
        'fromDate': fromDate!.toIso8601String(),
        'toDate': toDate!.toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leave request submitted successfully")),
      );

      // Clear form
      reason.clear();
      setState(() {
        selectedType = 'Casual Leave';
        fromDate = null;
        toDate = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  String _formatDate(DateTime? date) {
    return date == null ? "Select Date" : "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply Leave")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              items: ['Casual Leave', 'Sick Leave', 'Paid Leave']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => selectedType = value!),
              decoration: const InputDecoration(
                labelText: "Leave Type",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(context, true),
                    child: Text("From: ${_formatDate(fromDate)}"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(context, false),
                    child: Text("To: ${_formatDate(toDate)}"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reason,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Reason",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isSubmitting ? null : submitLeaveRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Request"),
            ),
          ],
        ),
      ),
    );
  }
}
