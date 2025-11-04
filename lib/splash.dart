import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymassist/routes/app_routes.dart';
import 'package:gymassist/utils/utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> _checkUserValidity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // This will throw an error if the user no longer exists in Firebase
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser == null) {
        // User was deleted on server
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'user-disabled') {
        await FirebaseAuth.instance.signOut();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2)); // small delay for logo

    await _checkUserValidity();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is already signed in
      Navigator.of(context).pushReplacementNamed(AppRoutes.homeWrapper);
    } else {
      // No user signed in
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo (replace with your asset later)
            Icon(Icons.fitness_center, size: 80, color: AppColors.accent),
            const SizedBox(height: 16),
            const Text(
              "Fitbuddy",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
