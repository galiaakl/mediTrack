import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack_new/doctorprofilepage.dart';

class VerificationHealthcarePage extends StatefulWidget {
  final String email;
  final String password;

  const VerificationHealthcarePage({
    super.key,
    required this.email,
    required this.password
  });

  @override
  _VerificationHealthcarePageState createState() => _VerificationHealthcarePageState();
}

class _VerificationHealthcarePageState extends State<VerificationHealthcarePage> {
  List<String> codeDigits = ['', '', '', ''];
  int currentIndex = 0;
  bool timerExpired = false;
  int timerSeconds = 120; // 2:00 in seconds
  Timer? _timer;
  bool showSuccessDialog = false;
  bool showTimerExpiredDialog = false;
  bool _isVerifying = false;
  String? _errorMessage;
  bool _showAdditionalInfo = false;

  // Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Timer for checking email verification
  Timer? _checkEmailVerificationTimer;

  @override
  void initState() {
    super.initState();
    startTimer();
    _sendVerificationEmail();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkEmailVerificationTimer?.cancel();
    super.dispose();
  }

  // Send verification email
  Future<void> _sendVerificationEmail() async {
    try {
      // In a real implementation, we would use Firebase's email verification
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else {
        // If user is not logged in, attempt to sign in
        try {
          await _auth.signInWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );
          user = _auth.currentUser;
          if (user != null && !user.emailVerified) {
            await user.sendEmailVerification();
          }
        } catch (e) {
          print('Error signing in to send verification: $e');
        }
      }
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  // Start checking for email verification
  void _startEmailVerificationCheck() {
    _checkEmailVerificationTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          timer.cancel();
          if (mounted) {
            // Update user verification status in Firestore
            await _updateVerificationStatus(user.uid);

            setState(() {
              showSuccessDialog = true;
            });
          }
        }
      }
    });
  }

  // Update user verification status in Firestore
  Future<void> _updateVerificationStatus(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating verification status: $e');
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timerSeconds > 0) {
          timerSeconds--;
        } else {
          timerExpired = true;
          timer.cancel();
          showTimerExpiredDialog = true;
        }
      });
    });
  }

  void resendCode() {
    setState(() {
      timerExpired = false;
      timerSeconds = 130;
      showTimerExpiredDialog = false;
    });
    _sendVerificationEmail();
    startTimer();
  }

  String formatTime() {
    int minutes = timerSeconds ~/ 60;
    int seconds = timerSeconds % 60;
    return '(${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')})';
  }

  void addDigit(String digit) {
    if (currentIndex < 4) {
      setState(() {
        codeDigits[currentIndex] = digit;
        currentIndex++;
      });

      // Check if code is complete
      if (currentIndex == 4) {
        verifyCode();
      }
    }
  }

  void removeDigit() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        codeDigits[currentIndex] = '';
      });
    }
  }

  bool isCodeComplete() {
    return !codeDigits.contains('');
  }

  void verifyCode() {
    if (isCodeComplete()) {
      setState(() {
        _isVerifying = true;
        _errorMessage = null;
      });

      // For this implementation, we're using Firebase's built-in email verification
      // system, so we'll check if the email has been verified
      _checkEmailVerification();
    }
  }

  // Check if email has been verified
  Future<void> _checkEmailVerification() async {
    try {
      setState(() {
        _isVerifying = true;
        _errorMessage = null;
      });

      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          // Update user verification status in Firestore
          await _updateVerificationStatus(user.uid);

          setState(() {
            _isVerifying = false;
            showSuccessDialog = true;
          });
        } else {
          setState(() {
            _isVerifying = false;
            _errorMessage = 'Please verify your email by clicking the link sent to ${widget.email}';
          });
        }
      } else {
        // Try to sign in
        try {
          await _auth.signInWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );
          _checkEmailVerification();
        } catch (e) {
          setState(() {
            _isVerifying = false;
            _errorMessage = 'Authentication error. Please try again.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Error checking verification. Please try again.';
      });
    }
  }

  void toggleAdditionalInfo() {
    setState(() {
      _showAdditionalInfo = !_showAdditionalInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF33D4C8),
            elevation: 0,
            title: Text(
              'Healthcare Verification',
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
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        // Title
                        Text(
                          'Verify Your Email',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Email verification instructions
                        Text(
                          'We sent a verification link to:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF33D4C8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Please check your email and click the verification link',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Healthcare provider specific notice
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 15),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Healthcare Provider Verification',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: toggleAdditionalInfo,
                                    child: Icon(
                                      _showAdditionalInfo
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              if (_showAdditionalInfo) ...[
                                SizedBox(height: 10),
                                Text(
                                  'As a healthcare provider, your account requires additional verification. After verifying your email, our team will review your credentials before activating your account. This usually takes 1-3 business days.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Display error message if any
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        SizedBox(height: 30),

                        // Code Input Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            4,
                                (index) => Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color(0xFFE3F8FC),
                                borderRadius: BorderRadius.circular(8),
                                border: currentIndex == index
                                    ? Border.all(color: Color(0xFF33D4C8), width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  codeDigits[index],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF33D4C8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),
                        // Timer and Resend Code
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formatTime(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Didn\'t receive email?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: timerExpired ? resendCode : null,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(10, 10),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Resend verification',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: timerExpired ? Color(0xFF33D4C8) : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30),
                        // Verify Button
                        ElevatedButton(
                          onPressed: _isVerifying ? null : _checkEmailVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF33D4C8),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Color(0xFF33D4C8).withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            minimumSize: Size(200, 50),
                          ),
                          child: _isVerifying
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text('I\'ve verified my email', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Number Pad
              Container(
                color: Colors.grey[200],
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        codeDigits.join(''),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Number Pad Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      children: [
                        // Numbers 1-9
                        for (int i = 1; i <= 9; i++)
                          NumPadButton(
                            text: '$i',
                            onPressed: () => addDigit('$i'),
                          ),
                        // Empty space
                        Container(),
                        // 0 Button
                        NumPadButton(text: '0', onPressed: () => addDigit('0')),
                        // Delete Button
                        NumPadButton(
                          onPressed: removeDigit,
                          child: Icon(Icons.backspace_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Success Dialog
        if (showSuccessDialog)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300,
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Color(0xFF33D4C8),
                          size: 36,
                        ),
                      ),
                      SizedBox(height: 15),
                      // Welcome Message
                      Text(
                        'Thank you for verifying!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF33D4C8),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'Your email has been verified. Our team will review your credentials and approve your account within 1-3 business days.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 20),
                      // Go to Home Page Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => DoctorProfilePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF33D4C8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: Size(200, 45),
                        ),
                        child: Text(
                          'Go to Home Page',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Timer Expired Dialog
        if (showTimerExpiredDialog)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        'Timer is up!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 25),
                      // Resend Code Button
                      ElevatedButton(
                        onPressed: resendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF33D4C8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: Size(200, 50),
                        ),
                        child: Text(
                          'Resend code',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class NumPadButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback onPressed;

  const NumPadButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            alignment: Alignment.center,
            child: child ?? Text(
              text ?? '',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}