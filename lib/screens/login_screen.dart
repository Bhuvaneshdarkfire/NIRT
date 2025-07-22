import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  bool isOTPSent = false;
  bool isLoading = false;
  String verificationId = '';

  void sendOTP() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty || phone.length < 10) {
      showMessage("Enter a valid phone number");
      return;
    }

    setState(() => isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91$phone",
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolve OTP (Android only)
        await FirebaseAuth.instance.signInWithCredential(credential);
        goToHome();
      },
      verificationFailed: (FirebaseAuthException e) {
        showMessage("Verification failed: ${e.message}");
        setState(() => isLoading = false);
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          isOTPSent = true;
          isLoading = false;
        });
        showMessage("OTP sent to +91$phone");
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  void verifyOTP() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      showMessage("Enter a valid 6-digit OTP");
      return;
    }

    setState(() => isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        goToHome();
      } else {
        showMessage("Login failed");
      }
    } catch (e) {
      showMessage("Error verifying OTP: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void goToHome() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = await FirebaseAuth.instance.currentUser;

    if (uid != null && userDoc != null) {
      // You can fetch isAdmin from Firestore if needed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      showMessage("User info not found.");
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Login")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.phone_android, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            Text("Verify Your Phone", style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 30),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            const SizedBox(height: 20),
            if (isOTPSent)
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter OTP"),
              ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: isOTPSent ? verifyOTP : sendOTP,
                    child: Text(isOTPSent ? "Verify OTP" : "Send OTP"),
                  ),
          ],
        ),
      ),
    );
  }
}
