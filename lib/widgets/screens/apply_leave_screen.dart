import 'package:flutter/material.dart';

class ApplyLeaveScreen extends StatelessWidget {
  final TextEditingController reasonController = TextEditingController();
  String selectedType = 'Casual Leave';

  ApplyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Apply Leave")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              items: ['Casual Leave', 'Sick Leave', 'Paid Leave']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => selectedType = value!,
              decoration: InputDecoration(labelText: "Leave Type"),
            ),
            TextField(controller: reasonController, decoration: InputDecoration(labelText: "Reason")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("Submit")),
          ],
        ),
      ),
    );
  }
}
