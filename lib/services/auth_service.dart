import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Step 1: Start phone number verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Step 2: Sign in using the SMS code (OTP)
  Future<User?> signInWithOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  /// Step 3: After login, ensure user exists in Firestore
  Future<void> handlePostLogin() async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: "no-user", message: "User not logged in");

    final uid = user.uid;
    final phone = user.phoneNumber ?? '';

    final userDocRef = _firestore.collection("users").doc(uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      // Create new user document
      await userDocRef.set({
        "name": "New User",
        "phone": phone,
        "isAdmin": false,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  /// Optional: Check if current user is admin
  Future<bool> isAdminUser() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userDoc = await _firestore.collection("users").doc(user.uid).get();
    return userDoc.data()?['isAdmin'] ?? false;
  }

  /// Logout the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
