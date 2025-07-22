import 'package:flutter/material.dart';

class EmployeeListScreen extends StatelessWidget {
  final List<String> employees = ["John Doe", "Bhuvanesh", "Ananya", "Ravi"];

   EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employees")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        separatorBuilder: (_, __) => SizedBox(height: 8),
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(employees[index], style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text("ID: EMP10${index + 1}"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to detailed attendance (optional)
              },
            ),
          );
        },
      ),
    );
  }
}
