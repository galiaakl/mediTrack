import 'package:flutter/material.dart';
import 'onboarding2.dart';
import '../profile_setup/register.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onNextPressed;
  final VoidCallback onSkipPressed;

  const OnboardingScreen({
    Key? key,
    required this.onNextPressed,
    required this.onSkipPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RegistrationPage(
                    onLogInPressed: () {},
                    onSignUpPressed: () {},
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Text(
                  'Skip',
                  style: TextStyle(color: Color(0xFF33D4C8), fontSize: 16),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF33D4C8)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image
                    Image.asset('assets/FindCareNearYou.png', height: 250),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Find Care Near You',
                      style: TextStyle(
                        color: Color(0xFF33D4C8),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Search hospitals, clinics and\npharmacies - with real-time wait times\nand availability.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Pagination indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF33D4C8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => OnboardingScreen2(
                          onNextPressed: () {},
                          onSkipPressed: () {},
                        ),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF33D4C8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
