import 'package:flutter/material.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  String? selectedLanguage;
  String phoneNumber = "+1 123-456-7890";
  String emailAddress = "example@email.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF33D4C8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Select Language Title
                const Text(
                  'Select Language',
                  style: TextStyle(
                    color: Color(0xFF33D4C8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDropdownField(selectedLanguage, (value) {
                  setState(() {
                    selectedLanguage = value;
                  });
                }, ['English', 'Spanish', 'French', 'German', 'Chinese']),
                const SizedBox(height: 24),

                // Phone Number
                _buildInfoField(
                  'Phone Number',
                  phoneNumber,
                  onEdit: () {
                    _showEditDialog('Phone Number', phoneNumber, (value) {
                      setState(() {
                        phoneNumber = value;
                      });
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Email Address
                _buildEmailField(
                  'Email Address',
                  emailAddress,
                  onEdit: () {
                    _showEditDialog('Email Address', emailAddress, (value) {
                      setState(() {
                        emailAddress = value;
                      });
                    });
                  },
                  onVerify: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification email sent!'),
                        backgroundColor: Color(0xFF33D4C8),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Logout Button
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      _showLogoutDialog();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildDropdownField(
      String? value,
      Function(String?) onChanged,
      List<String> items,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text(
            'Select Language',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          elevation: 0,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          onChanged: onChanged,
          items:
          items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoField(
      String label,
      String value, {
        required Function onEdit,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF33D4C8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          TextButton(
            onPressed: () => onEdit(),
            child: const Text(
              'Edit',
              style: TextStyle(color: Color(0xFF33D4C8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(
      String label,
      String value, {
        required Function onEdit,
        required Function onVerify,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF33D4C8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => onVerify(),
                child: const Text(
                  'Verify',
                  style: TextStyle(color: Color(0xFF33D4C8)),
                ),
              ),
              TextButton(
                onPressed: () => onEdit(),
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Color(0xFF33D4C8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      String field,
      String currentValue,
      Function(String) onSave,
      ) {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your $field',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSave(controller.text);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$field updated successfully'),
                  backgroundColor: const Color(0xFF33D4C8),
                ),
              );
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFF33D4C8)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Color(0xFF33D4C8),
                ),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
