import 'package:flutter/material.dart';

class LeaveStatusScreen extends StatelessWidget {
  const LeaveStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Leave Status")),
      body: Center(child: Text("No leave requests yet.")),
    );
  }
}
