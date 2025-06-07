import 'package:flutter/material.dart';
import 'customersupport.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF33D4C8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: Text(
            'Frequently Asked Questions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [SizedBox(width: 48)],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: const [
                  FAQItem(
                    question: 'What is MediTrack?',
                    answer:
                    'Meditrack is a healthcare accessibility app that helps you find medical facilities, pharmacies, book doctor appointments, and access emergency services quickly and easily.',
                  ),
                  FAQItem(
                    question: 'How do I book an appointment?',
                    answer:
                    'Simply search for a doctor or healthcare provider, select an available time slot, and confirm your booking directly through the app.',
                  ),
                  FAQItem(
                    question: 'Can I search for medicine nearby?',
                    answer:
                    'While the app helps you locate nearby pharmacies, it does not track the availability of specific medicines. You can contact the pharmacy directly for up-to-date information.',
                  ),
                  FAQItem(
                    question: 'What happens when I tap \'Dial help\'?',
                    answer:
                    'When you tap "I Have an emergency," you can either tap Dial Help to quickly request aid  or tap Get Aid Directions to instantly open the map and get the fastest route to the nearest hospital, emergency center, or aid facility.  When you tap "Dial Help", you\'ll quickly choose between contacting the Red Cross or Civil Defense. After selecting, the app will show a confirmation screen with a 2-minute timer. If you confirm, help will be dispatched; if not, the request cancels automatically.',
                  ),
                  FAQItem(
                    question: 'How do I register as a healthcare provider?',
                    answer:
                    'To register as a healthcare provider, simply select \'I\'m a Healthcare Professional\' on the app\'s login page. Fill in your professional details, upload your license verification, set your location and availability, and you\'re ready to connect with users!',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Text(
                    'Have more question?',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerSupportPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Contact Us',
                      style: TextStyle(
                        color: Color(0xFF33D4C8),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF33D4C8),
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

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({Key? key, required this.question, required this.answer})
      : super(key: key);

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        title: Text(
          widget.question,
          style: TextStyle(
            color: _isExpanded ? Color(0xFF33D4C8) : Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_down, color: Color(0xFF33D4C8)),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                widget.answer.isEmpty
                    ? 'Answer content goes here.'
                    : widget.answer,
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
