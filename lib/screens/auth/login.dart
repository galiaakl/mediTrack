// File: lib/login.dart (Regular Users)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:meditrack_new/screens/user/home_page.dart';
import 'package:meditrack_new/screens/profile_setup/choose.dart';
import 'package:meditrack_new/services/auth_service.dart';
import 'package:meditrack_new/services/google_auth.dart';

class LoginPage extends StatefulWidget {
  final bool? resetCompleted;

  const LoginPage({super.key, this.resetCompleted});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isResetEmailSending = false;
  // ❌ REMOVED: _rememberPassword - Firebase handles persistence automatically
  String? _errorMessage;
  String? _successMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  void initState() {
    super.initState();
    if (widget.resetCompleted == true) {
      _successMessage = 'Password reset successful! Please log in with your new password.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Sign in with email and password (SECURE VERSION)
  Future<void> _signIn() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userCredential = await authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (userCredential != null) {
        if (widget.resetCompleted == true) {
          await authService.updateVerificationStatus();
        }

        // Check if user is verified
        final isVerified = await authService.isEmailVerified();
        if (!isVerified) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Please verify your email before logging in. Check your email for the verification link.';
          });
          return;
        }

        // ❌ REMOVED: Password saving - Firebase handles persistence automatically

        // Successfully signed in, navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = authService.errorMessage ?? 'Failed to sign in';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Sign in with Google (REGULAR USER)
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Pass 'regular' as the userRole for general login page
      final userCredential = await _googleAuthService.signInWithGoogle(
        context,
        userRole: 'regular',
      );

      if (!mounted) return;

      if (userCredential != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google sign-in failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // Send password reset email
  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address to reset your password';
      });
      return;
    }

    try {
      setState(() {
        _isResetEmailSending = true;
        _errorMessage = null;
        _successMessage = null;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.sendPasswordResetLink(email);

      if (!mounted) return;

      if (success) {
        setState(() {
          _successMessage = 'Password reset link sent to $email. Please check your email.';
          _errorMessage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent to $email'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = authService.errorMessage ?? 'Failed to send password reset email';
          _successMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _successMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResetEmailSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF33D4C8),
        elevation: 0,
        title: const Text(
          'Log In',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/BigLogoNoText.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Medi',
                            style: TextStyle(
                              color: Color(0xFF33D4C8),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'Track',
                            style: TextStyle(
                              color: Color(0xFF33D4C8),
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Success message
              if (_successMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ),

              // Error message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),

              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email or Mobile Number',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter email or mobile number',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      fillColor: const Color(0xFFEEFBF8),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      fillColor: const Color(0xFFEEFBF8),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  // ❌ REMOVED: Remember Me checkbox - Firebase handles this automatically

                  // Forgot Password Button (moved to right side)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isResetEmailSending ? null : _sendPasswordResetEmail,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(10, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: _isResetEmailSending
                          ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF33D4C8),
                        ),
                      )
                          : const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF33D4C8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Enter Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF33D4C8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Enter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // OR LOGIN WITH
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR LOGIN WITH',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                ],
              ),

              const SizedBox(height: 20),

              // Google Sign In Button
              ElevatedButton(
                onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                child: _isGoogleLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/GoogleLogo.png',
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Sign Up Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserSelectionPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF33D4C8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}