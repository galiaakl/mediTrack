import 'package:flutter/material.dart';
import 'package:meditrack_new/screens/profile_setup/healthcarefirstpage.dart';
import 'regularuserfirstpage.dart';
import '../auth/signup.dart';
import '../auth/healthcare_signup.dart';

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({super.key});

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  String? _selectedOption;

  void _selectUserType(String userType) {
    setState(() {
      _selectedOption = userType;
    });
  }

  void _continueToNextScreen() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option to continue')),
      );
    } else if (_selectedOption == 'regular') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const RegularUserProfilePage()),
      );
    } else if (_selectedOption == 'healthcare') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ProfileUpdatePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/BigLogoNoText.png', // Update with your asset path
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Let's get acquainted",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "How will you be using this app?",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // User options
                _buildUserOption(
                  selected: _selectedOption == 'regular',
                  icon: Icons.person,
                  title: "I'm a regular user",
                  subtitle: "Locate services",
                  onTap: () => _selectUserType('regular'),
                  iconBackgroundColor: Color(0xFF33D4C8),
                  iconColor: Colors.white,
                ),
                const SizedBox(height: 16),
                _buildUserOption(
                  selected: _selectedOption == 'healthcare',
                  icon: Icons.medical_services_outlined,
                  title: "I'm a healthcare professional",
                  subtitle: "Provide services",
                  onTap: () => _selectUserType('healthcare'),
                  iconBackgroundColor: Colors.white,
                  iconColor: Colors.black54,
                ),

                const SizedBox(height: 30),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continueToNextScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF33D4C8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserOption({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconBackgroundColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE6F7F4) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Color(0xFF33D4C8) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border:
                iconBackgroundColor == Colors.white
                    ? Border.all(color: Colors.black26)
                    : null,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}