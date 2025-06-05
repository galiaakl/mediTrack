import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _showTerms = false;
  bool _showPrivacy = false;
  bool _agreedTerms = false;
  bool _understoodPrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(color: Color(0xFF33D4C8)),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back, color: Colors.white),
                        SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'About',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            color: Colors.white,
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.network(
                      'https://i.ibb.co/RTQM1r8S/IMG-1589.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'MediTrack',
                    style: TextStyle(
                      color: Color(0xFF33D4C8),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Terms & Privacy Options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Terms & Conditions
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showTerms = !_showTerms;
                        _showPrivacy = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      color: const Color(0xFFF5FFFE),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: Color(0xFF33D4C8),
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            _showTerms
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Color(0xFF33D4C8),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showTerms)
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF33D4C8)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Welcome to MediTrack 👋\n\n'
                                'Here’s what you need to know before you get started:\n\n'
                                '🔒 Your Data is Safe\n'
                                'We collect only what’s needed to offer you better care. Your info stays private and secure.\n\n'
                                '📅 Real Healthcare Connections\n'
                                'You can book doctors, check nearby pharmacies, and request emergency help — fast and easy.\n\n'
                                '🆘 Not a 911 Service\n'
                                'If you’re in a life-threatening emergency, please call local emergency numbers directly.',
                            style: TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _agreedTerms,
                              activeColor: Color(0xFF33D4C8),
                              onChanged: (value) {
                                setState(() {
                                  _agreedTerms = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Agree and Continue',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  // Privacy Policy
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showPrivacy = !_showPrivacy;
                        _showTerms = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      color: const Color(0xFFF5FFFE),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: Color(0xFF33D4C8),
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            _showPrivacy
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Color(0xFF33D4C8),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showPrivacy)
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF33D4C8)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'At MediTrack, your privacy matters. Here’s the quick version:\n\n'
                                '🔒 We Respect Your Privacy\n'
                                'Your personal info (like name, age, medical conditions) is used only to provide the best healthcare experience.\n\n'
                                '📍 Location Use\n'
                                'We use your location only to show nearby pharmacies, hospitals, and doctors—never shared without permission.',
                            style: TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _understoodPrivacy,
                              activeColor: Color(0xFF33D4C8),
                              onChanged: (value) {
                                setState(() {
                                  _understoodPrivacy = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'I understand',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF33D4C8),
        unselectedItemColor: Colors.grey,
        currentIndex: 4,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Maps'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'News',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('/schedule');
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/maps');
              break;
            case 3:
              Navigator.of(context).pushReplacementNamed('/news');
              break;
            case 4:
              Navigator.of(context).pushReplacementNamed('/account');
              break;
          }
        },
      ),
    );
  }
}
