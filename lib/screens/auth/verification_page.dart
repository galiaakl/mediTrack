// File: lib/screens/secure_verification_page.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack_new/screens/user/home_page.dart';
import 'package:meditrack_new/screens/doctor/doctorprofilepage.dart';

class SecureVerificationPage extends StatefulWidget {
  final String email;
  final String userRole;
  final String name;

  const SecureVerificationPage({
    Key? key,
    required this.email,
    required this.userRole,
    this.name = '',
  }) : super(key: key);

  @override
  _SecureVerificationPageState createState() => _SecureVerificationPageState();
}

class _SecureVerificationPageState extends State<SecureVerificationPage> {
  bool _isSendingEmail = false;
  bool _isVerifying = false;
  bool _emailSent = false;
  String? _errorMessage;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _verificationComplete = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initVerification();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initVerification() async {
    try {
      setState(() {
        _isSendingEmail = true;
      });

      // Check if user is already signed in
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        setState(() {
          _errorMessage = 'No user is currently signed in. Please try signing up again.';
          _isSendingEmail = false;
        });
        return;
      }

      // Send verification email
      await _sendVerificationEmail(currentUser);

      // Start checking verification status
      _startVerificationTimer();

      setState(() {
        _isSendingEmail = false;
        _emailSent = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing verification: $e');
      }
      setState(() {
        _errorMessage = 'Error: $e';
        _isSendingEmail = false;
      });
    }
  }

  Future<void> _sendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();

      if (kDebugMode) {
        print('✅ Verification email sent to: ${widget.email}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending verification email: $e');
      }
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

      if (user != null && user.emailVerified) {
        _confirmVerification();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking verification status: $e');
      }
    }
  }

  Future<void> _confirmVerification() async {
    try {
      setState(() {
        _isVerifying = true;
      });

      // Update user verification status in Firestore
      if (_auth.currentUser != null) {
        final batch = _firestore.batch();
        final userId = _auth.currentUser!.uid;

        // Update main users collection
        batch.update(_firestore.collection('users').doc(userId), {
          'isVerified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
        });

        // Update role-specific collection
        if (widget.userRole == 'healthcare') {
          batch.update(_firestore.collection('healthcare_providers').doc(userId), {
            'isVerified': true,
            'verifiedAt': FieldValue.serverTimestamp(),
          });
        } else {
          batch.update(_firestore.collection('regular_users').doc(userId), {
            'isVerified': true,
            'verifiedAt': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
      }

      setState(() {
        _isVerifying = false;
        _verificationComplete = true;
        _timer?.cancel();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error confirming verification: $e');
      }
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email resent to ${widget.email}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'No user is currently signed in';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resending verification email: $e');
      }
      setState(() {
        _errorMessage = 'Failed to resend verification email: $e';
      });
    } finally {
      setState(() {
        _isSendingEmail = false;
      });
    }
  }

  // Manual verification check for testing
  Future<void> _manuallyCheckVerification() async {
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

      await _auth.currentUser!.reload();

      if (_auth.currentUser!.emailVerified) {
        await _confirmVerification();
      } else {
        setState(() {
          _errorMessage = 'Email not yet verified. Please check your email and click the verification link.';
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during verification check: $e';
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
              : 'Email Verification',
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
            // Logo
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

            // Healthcare provider specific notice
            if (widget.userRole == 'healthcare')
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Healthcare Provider Notice',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'After verifying your email, our team will review your credentials before activating your account. This usually takes 1-3 business days.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),

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

            // Action buttons
            if (_emailSent) ...[
              // Manual check button
              ElevatedButton.icon(
                onPressed: _isVerifying ? null : _manuallyCheckVerification,
                icon: Icon(Icons.refresh),
                label: Text(
                  _isVerifying ? 'Checking...' : 'I\'ve verified my email',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF33D4C8),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Resend button
              TextButton.icon(
                onPressed: _isSendingEmail ? null : _resendVerificationEmail,
                icon: Icon(Icons.email),
                label: Text(
                  _isSendingEmail ? 'Sending...' : 'Resend Verification Email',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF33D4C8),
                ),
              ),
            ],

            SizedBox(height: 20),

            // Debug button for testing (only in debug mode)
            if (kDebugMode)
              TextButton(
                onPressed: () async {
                  // For testing - simulate verification
                  await _confirmVerification();
                },
                child: Text('DEBUG: Skip Email Verification'),
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
                if (widget.userRole == 'healthcare') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => DoctorProfilePage()),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
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
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}