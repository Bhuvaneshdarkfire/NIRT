import 'package:flutter/material.dart';
import 'apply_leave_screen.dart';
import 'attendance_history_screen.dart';
import 'leave_status_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => navigate(context, AttendanceHistoryScreen()),
              child: Text("Check In / Check Out"),
            ),
            ElevatedButton(
              onPressed: () => navigate(context, ApplyLeaveScreen()),
              child: Text("Apply Leave"),
            ),
            ElevatedButton(
              onPressed: () => navigate(context, LeaveStatusScreen()),
              child: Text("Leave Status"),
            ),
            ElevatedButton(
              onPressed: () => navigate(context, ProfileScreen()),
              child: Text("Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
