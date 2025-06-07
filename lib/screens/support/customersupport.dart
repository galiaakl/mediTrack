import 'package:flutter/material.dart';

class CustomerSupportPage extends StatefulWidget {
  const CustomerSupportPage({Key? key}) : super(key: key);

  @override
  State<CustomerSupportPage> createState() => _CustomerSupportPageState();
}

class _CustomerSupportPageState extends State<CustomerSupportPage> {
  String? selectedReason;
  String? selectedContactMethod;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF33D4C8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Customer Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              width: double.infinity,
              child: const Text(
                'For any enquiry or support, our help desk team is ready to assist you within 24 hours.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reason',
                      style: TextStyle(
                        color: Color(0xFF33D4C8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      'Select your reason',
                      selectedReason,
                          (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                      [
                        'Technical Support',
                        'Doctor/Specialist Issue',
                        'General Complaint',
                        'Maps/Navigation Issue',
                        'Other',
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Preferred Contact Method',
                      style: TextStyle(
                        color: Color(0xFF33D4C8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      'Select contact method',
                      selectedContactMethod,
                          (value) {
                        setState(() {
                          selectedContactMethod = value;
                        });
                      },
                      [
                        'Via Whatsapp',
                        'Via Email',
                        'Via Phone Call',
                        'Via SMS',
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Message',
                      style: TextStyle(
                        color: Color(0xFF33D4C8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Write Your Message...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Support request sent!'),
                              backgroundColor: Color(0xFF33D4C8),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF33D4C8),
                          minimumSize: const Size(120, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.white,
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
          ],
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
      String hint,
      String? value,
      Function(String?) onChanged,
      List<String> items,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          elevation: 0,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onChanged: onChanged,
          items:
          items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    );
  }
}
