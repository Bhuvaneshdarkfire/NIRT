import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final nameController = TextEditingController();
  final empIdController = TextEditingController();
  final phoneController = TextEditingController(); // This is for display only

  bool isLoading = false;

  void addEmployee() async {
    final name = nameController.text.trim();
    final empId = empIdController.text.trim();
    final phone = phoneController.text.trim();

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage("No authenticated user found.");
      return;
    }

    if (name.isEmpty || empId.isEmpty || phone.isEmpty) {
      showMessage("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      String uid = user.uid;
      DateTime now = DateTime.now();

      // 1. Store in 'users' collection (for role & login)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'phone': phone,
        'isAdmin': false,
        'createdAt': Timestamp.now(),
      });

      // 2. Store full employee data in 'employees' collection
      await FirebaseFirestore.instance.collection('employees').doc(uid).set({
        'uid': uid,
        'name': name,
        'phone': phone,
        'empId': empId,
        'joinedDate':
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
        'totalLeaves': 0,
        'approvedLeaves': 0,
        'rejectedLeaves': 0,
      });

      showMessage("Employee data saved successfully!");
      clearForm();
    } catch (e) {
      showMessage("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void clearForm() {
    nameController.clear();
    empIdController.clear();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      phoneController.text = currentUser.phoneNumber ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Employee Info")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: empIdController, decoration: const InputDecoration(labelText: "Employee ID")),
            TextField(controller: phoneController, enabled: false, decoration: const InputDecoration(labelText: "Phone")),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: addEmployee,
                    child: const Text("Submit"),
                  ),
          ],
        ),
      ),
    );
  }
}
