import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  int presentDays = 0;
  int totalLeaves = 0;
  String lastCheckIn = '';

  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    if (uid == null) return;

    // Fetch employee document using UID
    final empDoc = await FirebaseFirestore.instance.collection('employees').doc(uid).get();

    // Fetch latest attendance record
    final attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(uid)
        .collection('records')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    final latestAttendance = attendanceSnapshot.docs.isNotEmpty
        ? attendanceSnapshot.docs.first.data()['time_display'] ?? ''
        : 'N/A';

    if (empDoc.exists) {
      final data = empDoc.data()!;
      setState(() {
        name = data['name'] ?? '';
        presentDays = data['presentDays'] ?? 0;
        totalLeaves = data['totalLeaves'] ?? 0;
        lastCheckIn = latestAttendance;
      });
    }
  }

  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $name"),
        backgroundColor: Colors.indigo,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(uid ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  name.isNotEmpty ? name[0] : '',
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: const BoxDecoration(color: Colors.indigo),
            ),
            _buildDrawerItem(Icons.fingerprint, "Check-In / Check-Out", "/checkin"),
            _buildDrawerItem(Icons.beach_access, "Apply Leave", "/applyLeave"),
            _buildDrawerItem(Icons.list_alt, "Leave Status", "/leaveStatus"),
            _buildDrawerItem(Icons.person, "My Profile", "/profile"),
            _buildDrawerItem(Icons.history, "Attendance History", "/attendanceHistory"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard("Present Days", presentDays.toString(), Icons.event_available),
                _infoCard("Total Leaves", totalLeaves.toString(), Icons.airline_seat_flat),
                _infoCard("Last Check-In", lastCheckIn, Icons.access_time),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Quick Actions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _actionButton(Icons.fingerprint, "Check-In", "/checkin"),
                _actionButton(Icons.beach_access, "Apply Leave", "/applyLeave"),
                _actionButton(Icons.person, "Profile", "/profile"),
                _actionButton(Icons.history, "History", "/attendanceHistory"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      onTap: () => _navigateTo(route),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width / 3.3,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.indigo),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => _navigateTo(route),
      child: Container(
        width: 150,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.indigo, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.indigo),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
