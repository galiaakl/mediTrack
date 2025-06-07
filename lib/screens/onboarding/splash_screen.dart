// File: lib/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:meditrack_new/screens/user/home_page.dart';
import 'package:meditrack_new/screens/onboarding/onboarding1.dart';
import 'package:meditrack_new/services/auth_service.dart';
import 'package:meditrack_new/screens/doctor/doctorprofilepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Setup animation for logo
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // Check authentication state after splash animation
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Wait for animation to complete
    await Future.delayed(Duration(seconds: 3));

    if (!mounted) return;

    try {
      // Check if user is already logged in (Firebase handles persistence automatically)
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // User is already logged in, check if verified and get role
        final authService = Provider.of<AuthService>(context, listen: false);

        // Reload user to get latest status
        await currentUser.reload();

        // Check if email is verified
        final bool isVerified = await authService.isEmailVerified();

        if (isVerified) {
          // Get user role to determine where to navigate
          final String? userRole = await authService.getUserRole();

          if (userRole == 'healthcare') {
            // Healthcare user -> Doctor Profile Page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => DoctorProfilePage()),
            );
          } else {
            // Regular user -> Home Page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
          return;
        } else {
          // User exists but not verified, sign them out and go to onboarding
          await FirebaseAuth.instance.signOut();
        }
      }
    } catch (e) {
      // If there's any error checking auth state, proceed to onboarding
      print('Error checking auth state: $e');
    }

    // If we get here, user is not logged in, not verified, or there was an error
    // Direct them to the onboarding screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(
            onNextPressed: () {},
            onSkipPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'assets/BigLogoNoText.png',
                width: 120,
                height: 120,
              ),
            ),
            SizedBox(height: 30),
            // App Name
            FadeTransition(
              opacity: _animation,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Medi',
                      style: TextStyle(
                        color: Color(0xFF33D4C8),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Track',
                      style: TextStyle(
                        color: Color(0xFF33D4C8),
                        fontSize: 28,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33D4C8)),
            ),
          ],
        ),
      ),
    );
  }
}