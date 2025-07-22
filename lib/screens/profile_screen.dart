import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('employees').doc(uid).get();
        if (doc.exists) {
          setState(() {
            profileData = doc.data();
          });
        } else {
          profileData = {};
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Profile")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final name = profileData?['name'] ?? 'N/A';
    final email = profileData?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? 'N/A';
    final empId = profileData?['empId'] ?? 'N/A';
    final phone = profileData?['phone'] ?? 'N/A';
    final joinedDate = profileData?['joinedDate'] ?? 'N/A';
    final totalLeaves = profileData?['totalLeaves'] ?? 0;
    final approvedLeaves = profileData?['approvedLeaves'] ?? 0;
    final rejectedLeaves = profileData?['rejectedLeaves'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(height: 140, color: Colors.indigo.shade200),
                Positioned(
                  bottom: -40,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text("Employee ID: $empId", style: const TextStyle(fontSize: 16)),

            const Divider(height: 30, thickness: 1),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text("Phone"),
              subtitle: Text(phone),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("Joined Date"),
              subtitle: Text(joinedDate),
            ),

            const Divider(height: 30, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat("Total Leaves", totalLeaves),
                  _buildStat("Approved", approvedLeaves),
                  _buildStat("Rejected", rejectedLeaves),
                ],
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String title, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
