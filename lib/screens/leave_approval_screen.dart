import 'package:flutter/material.dart';

class LeaveApprovalScreen extends StatelessWidget {
  final List<Map<String, String>> leaveRequests = [
    {"name": "John", "type": "Sick Leave", "status": "Pending"},
    {"name": "Ananya", "type": "Casual Leave", "status": "Pending"},
  ];

  LeaveApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Leave Requests")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaveRequests.length,
        itemBuilder: (context, index) {
          final item = leaveRequests[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text("${item['name']} - ${item['type']}"),
              subtitle: Text("Status: ${item['status']}"),
              trailing: Wrap(
                spacing: 10,
                children: [
                  IconButton(icon: Icon(Icons.check_circle, color: Colors.green), onPressed: () {}),
                  IconButton(icon: Icon(Icons.cancel, color: Colors.red), onPressed: () {}),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
