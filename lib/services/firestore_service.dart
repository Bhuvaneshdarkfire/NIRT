import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // 👤 Add or update user profile
  Future<void> saveUserProfile(String name, String email, String phone) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'employee',
    });
  }

  // 📝 Apply for leave
  Future<void> applyLeave(String fromDate, String toDate, String reason) async {
    await _db.collection('leaves').add({
      'uid': uid,
      'fromDate': fromDate,
      'toDate': toDate,
      'reason': reason,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 📍 Check-in
  Future<void> checkIn(String location) async {
    final today = DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd
    await _db.collection('attendance').doc('$uid-$today').set({
      'uid': uid,
      'date': today,
      'checkIn': Timestamp.now(),
      'location': location,
    }, SetOptions(merge: true));
  }

  // 📍 Check-out
  Future<void> checkOut() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _db.collection('attendance').doc('$uid-$today').update({
      'checkOut': Timestamp.now(),
    });
  }
}
