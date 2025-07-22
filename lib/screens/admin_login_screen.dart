import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatelessWidget {
  final email = TextEditingController();
  final password = TextEditingController();

  AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Login")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50),
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.indigo),
            SizedBox(height: 20),
            Text("Welcome, Admin", style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
            SizedBox(height: 30),
            TextField(controller: email, decoration: InputDecoration(labelText: "Email")),
            SizedBox(height: 15),
            TextField(controller: password, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboardScreen()));
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
