import 'package:flutter/material.dart';
import 'dart:async';

import 'package:meditrack_new/home_page.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({Key? key}) : super(key: key);

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  // State variables for managing popups and timer
  bool showRedCrossPopup = false;
  bool showCivilDefencePopup = false;
  bool showSuccessPopup = false;
  int remainingSeconds = 60;
  Timer? countdownTimer;

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  // Start countdown timer
  void startCountdown() {
    countdownTimer?.cancel();
    setState(() {
      remainingSeconds = 60;
    });

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          // Time's up, close the popup
          cancelCall();
        }
      });
    });
  }

  // Show Red Cross calling popup
  void showRedCrossCall() {
    setState(() {
      showRedCrossPopup = true;
      showCivilDefencePopup = false;
      showSuccessPopup = false;
    });
    startCountdown();
  }

  // Show Civil Defence calling popup
  void showCivilDefenceCall() {
    setState(() {
      showRedCrossPopup = false;
      showCivilDefencePopup = true;
      showSuccessPopup = false;
    });
    startCountdown();
  }

  // Cancel call
  void cancelCall() {
    countdownTimer?.cancel();
    setState(() {
      showRedCrossPopup = false;
      showCivilDefencePopup = false;
      showSuccessPopup = false;
    });
  }

  // Confirm call and show success popup
  void confirmCall() {
    countdownTimer?.cancel();
    setState(() {
      showRedCrossPopup = false;
      showCivilDefencePopup = false;
      showSuccessPopup = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.red),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Image.network(
          'https://i.ibb.co/SDdVdR3f/erasebg-transformed-1.png',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Pink background container - customizable position and size
          Positioned(
            top: 105,
            bottom: 120,
            left: 10,
            right: 5,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 196, 191),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              // Emergency Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/SmallRedBox.png',
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        left: 120,
                        right: 10,
                        top: 20,
                        bottom: 5,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(width: 8),
                            Text(
                              'I have an emergency!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Choose Service text
              const Text(
                'Choose Service:',
                style: TextStyle(
                  fontSize: 24,
                  color: Color.fromARGB(255, 112, 112, 112),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              // Red Cross Button
              Container(
                width: 260,
                height: 160,
                child: ElevatedButton(
                  onPressed: showRedCrossCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://i.ibb.co/n8sM86sj/erasebg-transformed-2.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Red Cross',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'OR',
                style: TextStyle(
                  fontSize: 22,
                  color: Color.fromARGB(255, 112, 112, 112),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // Civil Defence Button
              Container(
                width: 260,
                height: 160,
                child: ElevatedButton(
                  onPressed: showCivilDefenceCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://i.ibb.co/hx1g2Fwf/erasebg-transformed-3.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Civil Defence',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Red Cross Popup
          if (showRedCrossPopup)
            _buildCallConfirmationPopup(
              'You\'re about to call\nthe Red Cross',
              'https://i.ibb.co/n8sM86sj/erasebg-transformed-2.png',
              formattedTime,
            ),

          // Civil Defence Popup
          if (showCivilDefencePopup)
            _buildCallConfirmationPopup(
              'You\'re about to call\nthe Civil Defence',
              'https://i.ibb.co/hx1g2Fwf/erasebg-transformed-3.png',
              formattedTime,
            ),

          // Success Popup
          if (showSuccessPopup) _buildSuccessPopup(context),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF33D4C8),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
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

  // Call confirmation popup (Red Cross or Civil Defence)
  Widget _buildCallConfirmationPopup(
      String title,
      String imageUrl,
      String time,
      ) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 300,
            margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Container(
                  width: 100,
                  height: 100,
                  child:
                  imageUrl.contains('erasebg-transformed-3.png')
                      ? Image.network(imageUrl, color: Color(0xFFFFBF50))
                      : Image.network(imageUrl, color: Colors.red),
                ),
                const SizedBox(height: 30),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel button
                    ElevatedButton(
                      onPressed: cancelCall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 1,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    // Confirm button
                    ElevatedButton(
                      onPressed: confirmCall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF33D4C8),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'The call will be automatically\ncancelled!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPopup(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          height: 300,
          margin: EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFFF0F5FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 40, color: Color(0xFF33D4C8)),
              ),
              const SizedBox(height: 20),
              Text(
                'Help is on its way!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF33D4C8),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We\'re here with you every step',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF33D4C8),
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 14,
                  ),
                ),
                child: const Text('Go to home', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
