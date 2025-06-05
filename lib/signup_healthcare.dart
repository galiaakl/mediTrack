import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'about.dart';
import 'login.dart';
import 'verification_healthcare.dart';

class SignUpHealthcarePage extends StatefulWidget {
  const SignUpHealthcarePage({super.key});

  @override
  _SignUpHealthcarePageState createState() => _SignUpHealthcarePageState();
}

class _SignUpHealthcarePageState extends State<SignUpHealthcarePage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  String _selectedCountryCode = '+961'; // Default country code
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _nameController.dispose();
    _specialtyController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    // Simple email validation
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _signUp() async {
    // Reset error message
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validate inputs
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your full name';
        _isLoading = false;
      });
      return;
    }

    // Validate email
    if (!isValidEmail(_emailController.text)) {
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

    // Validate mobile number
    if (_mobileController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a mobile number';
        _isLoading = false;
      });
      return;
    }

    // Validate specialty
    if (_specialtyController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your specialty';
        _isLoading = false;
      });
      return;
    }

    // Validate license number
    if (_licenseController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your license number';
        _isLoading = false;
      });
      return;
    }

    try {
      // Create user with Firebase
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      // Create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'mobileNumber': _mobileController.text.trim(),
        'countryCode': _selectedCountryCode,
        'specialty': _specialtyController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
        'userRole': 'healthcare',
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'isApproved': false, // Healthcare providers need approval
      });

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Navigate to healthcare verification page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationHealthcarePage(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getFirebaseAuthErrorMessage(e.code);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Firebase Auth error messages
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email or try logging in.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Image.asset(
                'assets/BigLogoNoText.png',
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

              // Full Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE3F8FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        hintText: 'Dr. John Doe',
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

              // Healthcare Specialty Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Specialty',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE3F8FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _specialtyController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        hintText: 'e.g. Cardiology, Pediatrics',
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

              // License Number Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'License Number',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE3F8FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _licenseController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        hintText: 'Medical License/Registration Number',
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
              SizedBox(height: 20),

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
              Text(
                'or sign up with',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 15),

              // Social Login Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Button
                  SocialButton(
                    icon: Text(
                      'G',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      // TODO: Implement Google Sign-in
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Google sign-in not implemented yet')),
                      );
                    },
                  ),
                  SizedBox(width: 20),

                  // Facebook Button
                  SocialButton(
                    icon: Text(
                      'f',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      // TODO: Implement Facebook Sign-in
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Facebook sign-in not implemented yet')),
                      );
                    },
                  ),
                  SizedBox(width: 20),

                  // Fingerprint Button
                  SocialButton(
                    icon: Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      // TODO: Implement Biometric Sign-in
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Biometric sign-in not implemented yet')),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 20),
              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'already have an account? ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
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

class SocialButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;

  const SocialButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        backgroundColor: Color(0xFF33D4C8),
        padding: EdgeInsets.all(12),
        minimumSize: Size(50, 50),
      ),
      child: icon,
    );
  }
}