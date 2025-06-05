// File: lib/screens/verification_page.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack_new/home_page.dart';
import 'package:meditrack_new/email_service.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  final String password;
  final String userRole;
  final String name;

  const VerificationPage({
    Key? key,
    required this.email,
    required this.password,
    required this.userRole,
    this.name = '',
  }) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isSendingEmail = false;
  bool _isVerifying = false;
  bool _emailSent = false;
  String? _errorMessage;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _verificationComplete = false;

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initAuth() async {
    try {
      setState(() {
        _isSendingEmail = true;
      });

      // Sign in the user with the provided credentials
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      // Send verification email
      await _sendVerificationEmail(userCredential.user!);

      // Start checking verification status
      _startVerificationTimer();

      setState(() {
        _isSendingEmail = false;
        _emailSent = true;
      });
    } catch (e) {
      print('Error initializing auth: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isSendingEmail = false;
      });
    }
  }

  Future<void> _sendVerificationEmail(User user) async {
    try {
      // Send email verification
      await user.sendEmailVerification();

      // For development purposes, show a message in the console
      print('🔗 Verification link sent to: ${widget.email}');
      print('📧 In a real environment, the user would click the link in their email.');
      print('👉 For testing, you can manually set the user as verified in Firestore.');

      // Also print instructions for manual verification
      print('✅ To manually verify this user:');
      print('1. In Firebase Console, go to Firestore');
      print('2. Find the user document with ID: ${user.uid}');
      print('3. Update the "isVerified" field to true');
    } catch (e) {
      print('Error sending verification email: $e');
      setState(() {
        _errorMessage = 'Failed to send verification email: $e';
      });
      throw e;
    }
  }

  void _startVerificationTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkVerificationStatus();
      setState(() {
        _secondsElapsed += 5;
      });
    });
  }

  Future<void> _checkVerificationStatus() async {
    if (_verificationComplete) return;

    try {
      // Reload user to get latest verification status
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;

      if (user != null) {
        // Check Firebase email verification status
        if (user.emailVerified) {
          _confirmVerification();
          return;
        }

        // Also check Firestore for manual verification
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists && docSnapshot.data()?['isVerified'] == true) {
          _confirmVerification();
        }
      }
    } catch (e) {
      print('Error checking verification status: $e');
    }
  }

  Future<void> _confirmVerification() async {
    try {
      setState(() {
        _isVerifying = true;
      });

      // Update user verification status in Firestore
      if (_auth.currentUser != null) {
        await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
          'isVerified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        _isVerifying = false;
        _verificationComplete = true;
        _timer?.cancel();
      });
    } catch (e) {
      print('Error confirming verification: $e');
      setState(() {
        _errorMessage = 'Error confirming verification: $e';
        _isVerifying = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() {
        _isSendingEmail = true;
        _errorMessage = null;
      });

      if (_auth.currentUser != null) {
        await _auth.currentUser!.sendEmailVerification();

        setState(() {
          _emailSent = true;
          _secondsElapsed = 0;
        });
      } else {
        // Re-authenticate if user is not logged in
        await _initAuth();
      }
    } catch (e) {
      print('Error resending verification email: $e');
      setState(() {
        _errorMessage = 'Failed to resend verification email: $e';
      });
    } finally {
      setState(() {
        _isSendingEmail = false;
      });
    }
  }

  // Manual verification for testing
  Future<void> _manuallyVerify() async {
    if (_auth.currentUser == null) {
      setState(() {
        _errorMessage = 'User not logged in';
      });
      return;
    }

    try {
      setState(() {
        _isVerifying = true;
        _errorMessage = null;
      });

      await _confirmVerification();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during manual verification: $e';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF33D4C8),
        elevation: 0,
        title: Text(
          widget.userRole == 'healthcare'
              ? 'Healthcare Verification'
              : 'Account Verification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _verificationComplete
          ? _buildSuccessContent()
          : _buildVerificationContent(),
    );
  }

  Widget _buildVerificationContent() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo or Image
            Image.asset(
              'assets/BigLogoNoText.png',
              height: 120,
              width: 120,
            ),
            SizedBox(height: 30),

            // Title
            Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),

            // Email Address Display
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 30),

            // Instructions
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _emailSent ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _emailSent ? Colors.green[200]! : Colors.blue[200]!,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _emailSent ? Icons.check_circle : Icons.email,
                    color: _emailSent ? Colors.green : Colors.blue,
                    size: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    _emailSent
                        ? 'Verification email sent!'
                        : 'Sending verification email...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _emailSent ? Colors.green[700] : Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _emailSent
                        ? 'Please check your email inbox and click on the verification link to complete your account setup.'
                        : 'We\'re preparing to send you a verification email. Please wait a moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _emailSent ? Colors.green[700] : Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ),

            SizedBox(height: 30),

            // Status message
            if (_emailSent)
              Text(
                'Waiting for verification...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

            SizedBox(height: 10),

            // Elapsed time indicator
            if (_emailSent)
              Text(
                'Time elapsed: ${(_secondsElapsed / 60).floor()}:${(_secondsElapsed % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),

            SizedBox(height: 30),

            // Resend button
            if (_emailSent)
              ElevatedButton.icon(
                onPressed: _isSendingEmail ? null : _resendVerificationEmail,
                icon: Icon(Icons.refresh),
                label: Text(
                  _isSendingEmail ? 'Sending...' : 'Resend Verification Email',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF33D4C8),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

            SizedBox(height: 20),

            // Debug button for testing
            if (kDebugMode)
              TextButton(
                onPressed: _manuallyVerify,
                child: Text('DEBUG: Manually Verify Email'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
            ),
            SizedBox(height: 30),

            // Success message
            Text(
              widget.userRole == 'healthcare'
                  ? 'Thank you for verifying!'
                  : 'Email Verified Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),

            // Success description
            Text(
              widget.userRole == 'healthcare'
                  ? 'Your email has been verified. Our team will review your credentials and approve your account within 1-3 business days.'
                  : 'Your email has been verified and your account is now active. You can now access all features of the app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 40),

            // Continue to app button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF33D4C8),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Continue to App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}