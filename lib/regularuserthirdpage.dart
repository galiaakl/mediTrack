import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'regularuserfourthpage.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final TextEditingController contact1Controller = TextEditingController();
  final TextEditingController contact2Controller = TextEditingController();
  final TextEditingController contact3Controller = TextEditingController();

  String selectedCountryCode1 = '+961';
  String selectedCountryCode2 = '+961';
  String selectedCountryCode3 = '+961';

  final List<Map<String, String>> countryCodes = [
    {'code': '+961', 'flag': '🇱🇧'},
    {'code': '+971', 'flag': '🇦🇪'},
    {'code': '+1', 'flag': '🇺🇸'},
    {'code': '+44', 'flag': '🇬🇧'},
    {'code': '+33', 'flag': '🇫🇷'},
    {'code': '+49', 'flag': '🇩🇪'},
  ];

  @override
  void dispose() {
    contact1Controller.dispose();
    contact2Controller.dispose();
    contact3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF33D4C8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Regular User',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can add up to three emergency contacts',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            _buildContactInput(
              label: 'Emergency Contact 1',
              controller: contact1Controller,
              selectedCountryCode: selectedCountryCode1,
              onCountryCodeChanged: (newCode) {
                setState(() {
                  selectedCountryCode1 = newCode!;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildContactInput(
              label: 'Emergency Contact 2',
              controller: contact2Controller,
              selectedCountryCode: selectedCountryCode2,
              onCountryCodeChanged: (newCode) {
                setState(() {
                  selectedCountryCode2 = newCode!;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildContactInput(
              label: 'Emergency Contact 3',
              controller: contact3Controller,
              selectedCountryCode: selectedCountryCode3,
              onCountryCodeChanged: (newCode) {
                setState(() {
                  selectedCountryCode3 = newCode!;
                });
              },
            ),

            const SizedBox(height: 24),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HealthInfoPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF33D4C8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInput({
    required String label,
    required TextEditingController controller,
    required String selectedCountryCode,
    required ValueChanged<String?> onCountryCodeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCountryCode,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF33D4C8),
                  ),
                  items:
                  countryCodes.map((Map<String, String> country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Row(
                        children: [
                          Text(
                            country['flag']!,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            country['code']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onCountryCodeChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE0F7F5),
                  hintText: 'Enter phone number',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
