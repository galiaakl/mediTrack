// File: lib/healthcare_signup.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack_new/services/auth_service.dart';
import 'package:meditrack_new/services/google_auth.dart';
import 'package:meditrack_new/screens/doctor/doctorprofilepage.dart';
import 'package:meditrack_new/screens/auth/login_healthcare.dart';
import 'package:meditrack_new/screens/support/about.dart'; // Import for Terms of Use and Privacy Policy
import 'verification_page.dart';

class HealthcareSignupPage extends StatefulWidget {
  const HealthcareSignupPage({super.key});

  @override
  _HealthcareSignupPageState createState() => _HealthcareSignupPageState();
}

class _HealthcareSignupPageState extends State<HealthcareSignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String _selectedCountryCode = '+961'; // Default country code
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  // List of country codes
  final List<CountryCode> _countryCodes = [
    CountryCode('+961', 'LB'),
    CountryCode('+44', 'UK'),
    CountryCode('+91', 'IN'),
    CountryCode('+61', 'AU'),
    CountryCode('+86', 'CN'),
    CountryCode('+49', 'DE'),
    CountryCode('+33', 'FR'),
    CountryCode('+81', 'JP'),
    CountryCode('+7', 'RU'),
    CountryCode('+55', 'BR'),
    CountryCode('+52', 'MX'),
    CountryCode('+27', 'ZA'),
    CountryCode('+234', 'NG'),
    CountryCode('+20', 'EG'),
    CountryCode('+82', 'KR'),
  ];

  // Google Auth Service
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  // Google Sign In
  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      // Pass 'healthcare' as the userRole for healthcare professionals
      final userCredential = await _googleAuthService.signInWithGoogle(
        context,
        userRole: 'healthcare',
      );

      if (!mounted) return;

      if (userCredential != null) {
        // After successful sign-in, update additional information
        await FirebaseFirestore.instance
            .collection('healthcare_providers')
            .doc(userCredential.user!.uid)
            .set({
          'userRole': 'healthcare',
          'email': userCredential.user!.email,
          'mobileNumber': _mobileController.text.trim(),
          'countryCode': _selectedCountryCode,
          'isVerified': true, // Google accounts are pre-verified
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Navigate to doctor profile page
        // NEW secure code:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SecureVerificationPage(
              email: _emailController.text.trim(),
              userRole: 'healthcare',
              name: '',
            ),
          ),
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

  // Email Sign Up
  Future<void> _signUp() async {
    // Reset error message
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validate required fields
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _mobileController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all required fields';
        _isLoading = false;
      });
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    // Validate email
    if (!authService.isValidEmail(_emailController.text)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
        _isLoading = false;
      });
      return;
    }

    // Validate password (at least 6 characters)
    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
        _isLoading = false;
      });
      return;
    }

    try {
      // Create user with Firebase
      final result = await authService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        mobileNumber: _mobileController.text.trim(),
        countryCode: _selectedCountryCode,
        userRole: 'healthcare',
      );

      setState(() {
        _isLoading = false;
      });

      if (result['error'] == null && mounted) {
        // After successful sign-up, navigate to doctor profile page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfilePage(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to create account';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF33D4C8),
        elevation: 0,
        title: Text(
          'Healthcare Provider Signup',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),

              // App Logo
              Image.asset(
                'assets/SignUpWithGoogle.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30),

              // Display error message if any
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
                  Text(
                    'Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE3F8FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        hintText: 'doctor@example.com',
                        hintStyle: TextStyle(
                          color: Color(0xFF33D4C8).withOpacity(0.7),
                        ),
                      ),
                      style: TextStyle(color: Color(0xFF33D4C8)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE3F8FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        hintText: '************',
                        hintStyle: TextStyle(
                          color: Color(0xFF33D4C8).withOpacity(0.7),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Color(0xFF33D4C8),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(color: Color(0xFF33D4C8)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Mobile Number Field with Country Code
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mobile Number',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country Code Dropdown
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFE3F8FC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF33D4C8),
                            ),
                            style: TextStyle(color: Color(0xFF33D4C8)),
                            isDense: true, // make it more compact
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCountryCode = newValue!;
                              });
                            },
                            items:
                            _countryCodes.map<DropdownMenuItem<String>>((
                                CountryCode code,
                                ) {
                              return DropdownMenuItem<String>(
                                value: code.dialCode,
                                child: Text(
                                  '${code.dialCode} (${code.countryCode})',
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Mobile Number Text Field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFE3F8FC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _mobileController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 15,
                              ),
                              hintText: '123456789',
                              hintStyle: TextStyle(
                                color: Color(0xFF33D4C8).withOpacity(0.7),
                              ),
                            ),
                            style: TextStyle(color: Color(0xFF33D4C8)),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Terms of Use and Privacy Policy
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'By continuing, you agree to ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => (AboutPage())),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(10, 10),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Terms of Use and Privacy Policy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF33D4C8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Sign Up Button
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF33D4C8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Sign Up', style: TextStyle(fontSize: 16)),
              ),


              SizedBox(height: 15),

              // Google Sign-In Button
              GoogleSignInButton(
                isLoading: _isGoogleLoading,
                onPressed: _signUpWithGoogle,
              ),

              SizedBox(height: 20),

              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HealthcareLoginPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(10, 10),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        color: Color(0xFF33D4C8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Country code class
class CountryCode {
  final String dialCode;
  final String countryCode;

  CountryCode(this.dialCode, this.countryCode);
}

// Google Sign-In Button Widget
class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: isLoading
          ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33D4C8)),
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/google_logo.png',
            height: 24,
            width: 24,
          ),
          SizedBox(width: 10),
          Text(
            'Sign up with Google',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}