import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Time';
    final dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy – hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid ?? '';

    print('🔍 Logged-in UID: $uid');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('uid', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('❌ Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }

          final attendanceDocs = snapshot.data!.docs;

          // Debugging
          print("📦 Fetched ${attendanceDocs.length} attendance records.");

          return ListView.builder(
            itemCount: attendanceDocs.length,
            itemBuilder: (context, index) {
              final data = attendanceDocs[index].data() as Map<String, dynamic>;

              final type = data['type'] ?? 'Unknown';
              final timestamp = data['timestamp'] as Timestamp?;
              final timeDisplay = formatTimestamp(timestamp);
              final location = 'Lat: ${data['latitude'] ?? 'N/A'}, Lng: ${data['longitude'] ?? 'N/A'}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                child: ListTile(
                  leading: Icon(
                    type == 'Check-In' ? Icons.login : Icons.logout,
                    color: type == 'Check-In' ? Colors.green : Colors.red,
                  ),
                  title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time: $timeDisplay'),
                      Text(location),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
