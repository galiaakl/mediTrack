import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../support/about.dart';
import 'login.dart';
import '../../services/auth_service.dart';
import '../../services/google_auth.dart';  // Import the Google Auth service
import '../user/home_page.dart';    // Make sure to import HomePage
import 'verification_page.dart';

class SignUpPage extends StatefulWidget {
  final String userRole;

  const SignUpPage({super.key, required this.userRole});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;  // Moved to State class
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  String _selectedCountryCode = '+961'; // Default country code
  String? _errorMessage;

  // Moved to State class
  final GoogleAuthService _googleAuthService = GoogleAuthService();

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
    super.dispose();
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await _googleAuthService.signInWithGoogle(
        context,
        userRole: widget.userRole,  // Pass the user role
      );

      if (!mounted) return;

      if (userCredential != null) {
        // Successfully signed in with Google
        // Navigate to home page since Google accounts are pre-verified
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

  Future<void> _signUp() async {
    // Reset error message
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

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

    // Validate mobile number (any input is fine for now)
    if (_mobileController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a mobile number';
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
        userRole: widget.userRole,
        name: '', // You can add a name field to your signup form if needed
      );

      setState(() {
        _isLoading = false;
      });

      if (result['error'] == null && mounted) {
        // Navigate to verification page
        // NEW secure code:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecureVerificationPage(
              email: _emailController.text.trim(),
              userRole: widget.userRole,
              name: '',
            ),
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
      appBar: AppBar(
        backgroundColor: Color(0xFF33D4C8),
        elevation: 0,
        title: Text(
          'New Account',
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
                'assets/SignUpWith Google.png',
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

              // Email/Username Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email/Username',
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
                        hintText: 'example@example.com',
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

              // Google Sign-In Button
              GoogleSignInButton(
                isLoading: _isGoogleLoading,
                onPressed: _signUpWithGoogle,
              ),

              SizedBox(height: 20),

              // Social Login Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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