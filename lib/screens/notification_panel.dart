import 'package:flutter/material.dart';

class NotificationPanelScreen extends StatelessWidget {
  final List<String> notifications = [
    "John checked in at 9:01 AM",
    "Ananya applied for leave",
    "Ravi checked in late",
  ];

   NotificationPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.notifications_active, color: Colors.indigo),
          title: Text(notifications[index]),
        ),
      ),
    );
  }
}
