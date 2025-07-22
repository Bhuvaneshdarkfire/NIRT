import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  bool isCheckingIn = true;
  bool isLoading = false;
  Position? lastPosition;
  String? lastTime;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    _fetchUserPhone();
  }

  Future<void> _fetchUserPhone() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data()?['phone'] != null) {
      setState(() {
        userPhone = userDoc['phone'];
      });
    }
  }

  Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _submitLocation() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final position = await _getLocation();
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm a, dd MMM yyyy').format(now);

      await FirebaseFirestore.instance.collection("attendance").add({
        "uid": user.uid,
        "phone": userPhone ?? "",
        "type": isCheckingIn ? "Check-In" : "Check-Out",
        "latitude": position.latitude,
        "longitude": position.longitude,
        "timestamp": now.toIso8601String(),
        "time_display": formattedTime,
      });

      setState(() {
        isCheckingIn = !isCheckingIn;
        lastPosition = position;
        lastTime = formattedTime;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${isCheckingIn ? "Check-out" : "Check-in"} recorded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Check-In / Check-Out")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 100, color: Colors.indigo),
            const SizedBox(height: 10),
            Text(
              "Ready to ${isCheckingIn ? "Check-In" : "Check-Out"}?",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (userPhone != null)
              Text("Logged in as: $userPhone", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isLoading ? null : _submitLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckingIn ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isCheckingIn ? "Check In" : "Check Out"),
            ),
            const SizedBox(height: 30),
            if (lastPosition != null && lastTime != null) ...[
              const Divider(),
              Text("Last Submission", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text("Time: $lastTime"),
              Text("Lat: ${lastPosition!.latitude.toStringAsFixed(4)}, "
                  "Long: ${lastPosition!.longitude.toStringAsFixed(4)}"),
            ]
          ],
        ),
      ),
    );
  }
}
