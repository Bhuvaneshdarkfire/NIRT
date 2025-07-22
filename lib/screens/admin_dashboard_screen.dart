import 'package:flutter/material.dart';
import 'employee_list_screen.dart';
import 'leave_approval_screen.dart';
import 'notification_panel.dart';
import 'add_employee_screen.dart'; // <- import your AddEmployeeScreen
import 'add_admin_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCard(
              context,
              "Employee List",
              Icons.people,
              () => navigate(context, EmployeeListScreen()),
            ),
            _buildCard(
              context,
              "Leave Approvals",
              Icons.assignment_turned_in,
              () => navigate(context, LeaveApprovalScreen()),
            ),
            _buildCard(
              context,
              "Notifications",
              Icons.notifications,
              () => navigate(context, NotificationPanelScreen()),
            ),
            _buildCard(
              context,
              "Add New Employee",
              Icons.person_add,
              () => navigate(context, AddEmployeeScreen()), // <- added new card
            ),
            _buildCard(context, "Add Admin", Icons.admin_panel_settings,
            () => navigate(context, AddAdminScreen())),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.indigo),
        title: Text(title, style: TextStyle(fontSize: 18)),
        trailing: Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
