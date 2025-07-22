import 'package:attendence_app/screens/checkin_checkout_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/checkin_checkout_screen.dart';
import 'screens/apply_leave_screen.dart';
import 'screens/leave_status_screen.dart';
import 'screens/attendance_history_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAhOI1iM1C10B19fOnWff3y_bNLq8YwNTI",
        authDomain: "attendance-app-fa665.firebaseapp.com",
        projectId: "attendance-app-fa665",
        storageBucket: "attendance-app-fa665.firebasestorage.app",
        messagingSenderId: "159235295282",
        appId: "1:159235295282:web:f9e66ed74819f6819c142b",
        measurementId: "G-PWZ41B4W96",
      ),
    );
  }  else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        ),
      ),

      // 🔁 All routes defined here for navigation safety
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/checkin': (context) => const CheckInOutScreen(),
        '/applyLeave': (context) => const ApplyLeaveScreen(),
        '/leaveStatus': (context) => const LeaveStatusScreen(),
        '/attendanceHistory': (context) => const AttendanceHistoryScreen(),
        '/myProfile': (context) => const ProfileScreen(),
      },
    );
  }
}
