// File: lib/reset_password.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:meditrack_new/screens/auth/login.dart';
import 'package:meditrack_new/services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String oobCode; // The action code from the email link

  const ResetPasswordPage({Key? key, required this.oobCode}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Debug - print the oobCode to check if it's valid
    print('📝 Reset Password Page initialized with oobCode: ${widget.oobCode}');
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Reset password with the oobCode
  Future<void> _resetPassword() async {
    // Validate passwords
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a new password';
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Debug output
      print('🔐 Attempting to reset password with oobCode: ${widget.oobCode}');
      print('   New password length: ${_passwordController.text.length}');

      // Get the email from the oobCode (useful for debugging)
      String? email;
      try {
        email = await _auth.verifyPasswordResetCode(widget.oobCode);
        print('✓ OobCode verified for email: $email');
      } catch (e) {
        print('✗ Error verifying oobCode: $e');
        // Continue with the password reset attempt
      }

      // Confirm password reset
      await _auth.confirmPasswordReset(
        code: widget.oobCode,
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      // Update email verification status in Firestore if the email is known
      if (email != null) {
        try {
          // Temporarily sign in to get the user ID
          final userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: _passwordController.text,
          );

          // Update verification status
          final authService = Provider.of<AuthService>(context, listen: false);
          await authService.updateVerificationStatus();

          // Sign out immediately (user will sign in through login page)
          await _auth.signOut();
        } catch (e) {
          print('Error updating verification status after password reset: $e');
          // Continue with normal flow even if this fails
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password has been reset successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage(resetCompleted: true)),
      );
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Exception in resetPassword:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      setState(() {
        _errorMessage = _getFirebaseAuthErrorMessage(e.code);
      });
    } catch (e) {
      print('❌ General Error in resetPassword: $e');
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

  // Get error message based on Firebase error code
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'expired-action-code':
        return 'The password reset link has expired. Please request a new one.';
      case 'invalid-action-code':
        return 'The password reset link is invalid. Please request a new one.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for this reset link.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      default:
        return 'An error occurred. Please try again.';
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
          'Reset Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    // Logo image
                    Image.asset(
                      'assets/BigLogoNoText.png', // Update with your logo path
                      width: 100,
                      height: 100,
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

              const Text(
                'Create a New Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your password must be at least 6 characters long and include a combination of numbers, letters, and special characters for better security.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

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

              // New Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Password',
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
                      hintText: 'Enter new password',
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
                ],
              ),

              const SizedBox(height: 20),

              // Confirm Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Confirm Password',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
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
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Reset Password Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
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
                    'Reset Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Back to Login
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Color(0xFF33D4C8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}