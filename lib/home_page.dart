import 'package:flutter/material.dart';
import 'package:meditrack_new/maps.dart';
import 'package:meditrack_new/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'book_appointment.dart';
import 'emergency.dart';
import 'emergency_map.dart';
import 'local_image_service.dart';
import 'alerts.dart';
import 'schedule.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables to store user data
  String userName = 'User';
  ImageProvider? userProfileImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data including profile image
  Future<void> _loadUserData() async {
    if (kDebugMode) {
      print("HomePage: Starting to load user data");
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          print("HomePage: No current user found");
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (kDebugMode) {
        print("HomePage: Current user ID: ${currentUser.uid}");
      }

      // Load user data from Firestore - try both collections
      DocumentSnapshot? userDoc;

      try {
        // First try users collection
        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (kDebugMode) {
          print("HomePage: User document exists: ${userDoc.exists}");
        }
      } catch (e) {
        if (kDebugMode) {
          print("HomePage: Error fetching from users collection: $e");
        }
      }

      // If not found in users, try healthcare_providers
      if (userDoc == null || !userDoc.exists) {
        try {
          userDoc = await FirebaseFirestore.instance
              .collection('healthcare_providers')
              .doc(currentUser.uid)
              .get();

          if (kDebugMode) {
            print("HomePage: Healthcare provider document exists: ${userDoc.exists}");
          }
        } catch (e) {
          if (kDebugMode) {
            print("HomePage: Error fetching from healthcare_providers collection: $e");
          }
        }
      }

      // Process the document if found
      if (userDoc != null && userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Set user name
        setState(() {
          userName = userData['displayName'] ?? userData['name'] ?? currentUser.displayName ?? 'User';
        });

        if (kDebugMode) {
          print("HomePage: Set user name to: $userName");
        }

        // Check for imageBase64 field
        if (userData.containsKey('imageBase64') && userData['imageBase64'] != null) {
          if (kDebugMode) {
            print("HomePage: Found imageBase64 field with length: ${userData['imageBase64'].toString().length}");
          }

          try {
            // Decode base64 string to bytes
            final bytes = base64Decode(userData['imageBase64']);

            if (kDebugMode) {
              print("HomePage: Successfully decoded base64 image, byte length: ${bytes.length}");
            }

            // Set the profile image
            setState(() {
              userProfileImage = MemoryImage(Uint8List.fromList(bytes));
            });
          } catch (e) {
            if (kDebugMode) {
              print("HomePage: Error decoding base64 image: $e");
            }
          }
        } else {
          if (kDebugMode) {
            print("HomePage: No imageBase64 field found in document");
            print("HomePage: Available fields: ${userData.keys.toList()}");
          }
        }
      } else {
        if (kDebugMode) {
          print("HomePage: No user document found in either collection");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("HomePage: Error loading user data: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF33D4C8)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Image.asset('assets/LogoNoText.png', height: 30),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33D4C8)),
        ),
      )
          : Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Profile picture
                      GestureDetector(
                        onTap: () {
                          // Refresh the profile image for debugging
                          if (kDebugMode) {
                            _loadUserData();
                          }
                        },
                        child: _buildProfilePicture(),
                      ),
                      const SizedBox(width: 8),
                      // Location text
                      const Text(
                        'Beirut, Lebanon',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),

                      const Spacer(),
                      // Three dots menu
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Medicines, Doctors, Etc.',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF33D4C8)),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Emergency Red Box
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/RedBox.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        // Buttons
                        Positioned(
                          bottom: 20,
                          left: 110,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Dial Help Button
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                              context) => const EmergencyPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF33D4C8),
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    child: const Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 0),
                                  const Text(
                                    'Dial Help',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              // Get Aid Directions Button
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                          const EmergencyMapsScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        199,
                                        196,
                                        196,
                                      ),
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    child: const Icon(
                                      Icons.directions,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 0),
                                  const Text(
                                    'Get Aid Directions',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Find a service section
                  const Text(
                    'Find a service',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Book an appointment card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppointmentsPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.assignment,
                              color: Color(0xFF33D4C8),
                              size: 30,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Book an appointment',
                                  style: TextStyle(
                                    color: Color(0xFF33D4C8),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Locate nearby facilities card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapsScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_hospital,
                              color: Color(0xFF33D4C8),
                              size: 30,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Locate nearby facilities',
                                  style: TextStyle(
                                    color: Color(0xFF33D4C8),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
            // Stay on HomePage
              break;
            case 1:
            // Navigate to SchedulePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SchedulePage()),
              );
              break;
            case 2:
            // Navigate to MapsScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapsScreen()),
              );
              break;
            case 3:
            // Navigate to TrafficAlertsPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrafficAlertsPage()),
              );
              break;
            case 4:
            // Navigate to ProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildProfilePicture() {
    return FutureBuilder<ImageProvider?>(
      future: LocalImageService.getProfileImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE0E0E0),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33D4C8)),
              ),
            ),
          );
        } else {
          return CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE0E0E0),
            backgroundImage: snapshot.data,
            child: snapshot.data == null
                ? Icon(Icons.person, size: 16, color: Colors.grey)
                : null,
          );
        }
      },
    );
  }
}