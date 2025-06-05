// File: lib/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:meditrack_new/home_page.dart';
import 'package:meditrack_new/onboarding1.dart';
import 'package:meditrack_new/auth_service.dart';
import 'package:meditrack_new/google_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Check if user is already logged in
    final authService = Provider.of<AuthService>(context, listen: false);
    final googleAuthService = GoogleAuthService();

    // Check if auto-login is enabled
    final bool isAutoLoginEnabled = await authService.isAutoLoginEnabled();

    if (isAutoLoginEnabled) {
      // Try to auto-login with saved credentials
      UserCredential? userCredential = await authService.autoLogin();

      // If no email/password credentials, try Google auto-login
      User? user = userCredential?.user;
      if (user == null) {
        user = await googleAuthService.autoLoginWithGoogle();
      }

      if (user != null) {
        // Reload user to get latest status
        await user.reload();

        // Check if email is verified
        bool isVerified = false;
        if (user.emailVerified) {
          isVerified = true;
        } else {
          // Check in Firestore
          isVerified = await authService.isEmailVerified();
        }

        if (isVerified) {
          // User is logged in and verified, go to home page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          return;
        }
      }
    }

    // If we get here, user is not auto-logged in or not verified
    // Direct them to the onboarding screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(
          onNextPressed: () {},
          onSkipPressed: () {},
        ),
      ),
    );
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