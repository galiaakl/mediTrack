import 'package:flutter/material.dart';
import 'accountsettings.dart';
import '../support/helpandsupport.dart';
import 'schedule.dart';
import '../support/about.dart';
import 'alerts.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/local_image_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/image_selector.dart';
import 'maps.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "User";
  File? _profileImage;
  bool _isUploading = false;
  bool _isLoading = true;
  String? _base64Image;
  ImageProvider? userProfileImage;

  // Medical data
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  List<String> medicalConditions = ["Diabetes", "Asthma"];
  List<String> allergies = ["Penicillin", "Nuts"];
  final medicationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data including profile image
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First try to load from SharedPreferences for name
      final prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');

      if (userDataString != null) {
        Map<String, dynamic> userData = json.decode(userDataString);
        setState(() {
          userName = userData['displayName'] ?? 'User';
        });
      }

      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load user data from Firestore - try both collections
      DocumentSnapshot? userDoc;

      try {
        // First try users collection
        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
      } catch (e) {
        print("Error fetching from users collection: $e");
      }

      // If not found in users, try healthcare_providers
      if (userDoc == null || !userDoc.exists) {
        try {
          userDoc = await FirebaseFirestore.instance
              .collection('healthcare_providers')
              .doc(currentUser.uid)
              .get();
        } catch (e) {
          print("Error fetching from healthcare_providers collection: $e");
        }
      }

      // Process the document if found
      if (userDoc != null && userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Set user name
        setState(() {
          userName = userData['displayName'] ?? userData['name'] ?? currentUser.displayName ?? 'User';
        });

        // Check for imageBase64 field
        if (userData.containsKey('imageBase64') && userData['imageBase64'] != null) {
          try {
            setState(() {
              _base64Image = userData['imageBase64'];
            });

            // Decode base64 string to bytes
            final bytes = base64Decode(userData['imageBase64']);
            setState(() {
              userProfileImage = MemoryImage(Uint8List.fromList(bytes));
            });
          } catch (e) {
            print("Error decoding base64 image: $e");
          }
        }
      }

      // Try to load local image if no Firebase image
      if (userProfileImage == null) {
        ImageProvider? localImage = await LocalImageService.getProfileImage();
        if (localImage != null) {
          setState(() {
            userProfileImage = localImage;
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to update profile picture
  Future<void> _updateProfilePicture() async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Use the ImageSelector to pick an image
      File? selectedImage = await ImageSelector.selectImage();

      // If image was selected, update the state
      if (selectedImage != null) {
        setState(() {
          _profileImage = selectedImage;
          userProfileImage = FileImage(selectedImage);
        });

        // Get current user
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Save as base64 in Firestore
          await _saveImageAsBase64(_profileImage!, currentUser.uid);
        }

        // Also save locally
        await LocalImageService.saveProfileImage(_profileImage!);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting profile picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Save image as base64 in Firestore
  Future<void> _saveImageAsBase64(File imageFile, String userId) async {
    try {
      // Read and encode image
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Check size - Firestore has a 1MB document limit
      if (base64Image.length > 500000) {  // Keeping some margin below 1MB
        throw Exception('Image too large for storage. Please select a smaller image.');
      }

      // Try to save to users collection first
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'imageBase64': base64Image});

        setState(() {
          _base64Image = base64Image;
        });
        return;
      } catch (e) {
        print('Error updating users collection: $e');
      }

      // If failed, try healthcare_providers collection
      try {
        await FirebaseFirestore.instance
            .collection('healthcare_providers')
            .doc(userId)
            .update({'imageBase64': base64Image});

        setState(() {
          _base64Image = base64Image;
        });
      } catch (e) {
        print('Error updating healthcare_providers collection: $e');
        throw e;
      }
    } catch (e) {
      print('Error storing image as base64: $e');
      throw e;
    }
  }

  Widget _buildProfileImage() {
    if (_isUploading) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Color(0xFFE0E0E0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33D4C8)),
        ),
      );
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFE0E0E0),
          backgroundImage: _profileImage != null
              ? FileImage(_profileImage!)
              : userProfileImage,
          child: (userProfileImage == null && _profileImage == null)
              ? Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: InkWell(
            onTap: _updateProfilePicture,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFF33D4C8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditMedicalDataDialog() {
    // Creates a StatefulBuilder to manage state within the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Creates local copies of the lists to manage within the dialog
        List<String> localMedicalConditions = List.from(medicalConditions);
        List<String> localAllergies = List.from(allergies);
        TextEditingController localWeightController = TextEditingController(
          text: weightController.text,
        );
        TextEditingController localHeightController = TextEditingController(
          text: heightController.text,
        );
        TextEditingController localMedicationController = TextEditingController(
          text: medicationController.text,
        );

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Edit Medical Data",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF33D4C8),
                        ),
                      ),
                    ),
                    Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Weight",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                localWeightController,
                                                decoration: InputDecoration(
                                                  hintText: "type",
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                                keyboardType:
                                                TextInputType.number,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                              ),
                                              child: Text(
                                                "Kg",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Height",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                localHeightController,
                                                decoration: InputDecoration(
                                                  hintText: "type",
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                                keyboardType:
                                                TextInputType.number,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                              ),
                                              child: Text(
                                                "cm",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),

                            // Medical Conditions Section
                            Text(
                              "Medical Conditions",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (String condition in localMedicalConditions)
                                  Chip(
                                    label: Text(condition),
                                    backgroundColor: Color(0xFFE0F7FA),
                                    deleteIconColor: Colors.grey,
                                    onDeleted: () {
                                      setState(() {
                                        localMedicalConditions.remove(
                                          condition,
                                        );
                                      });
                                    },
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: Icon(Icons.add, color: Color(0xFF33D4C8)),
                              label: Text(
                                "Add Another Condition",
                                style: TextStyle(color: Color(0xFF33D4C8)),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Color(0xFF33D4C8),
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Color(0xFF33D4C8)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                TextEditingController conditionController =
                                TextEditingController();
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                    title: Text("Add Medical Condition"),
                                    content: TextField(
                                      controller: conditionController,
                                      decoration: InputDecoration(
                                        hintText: "Enter condition name",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (conditionController
                                              .text
                                              .isNotEmpty) {
                                            setState(() {
                                              localMedicalConditions.add(
                                                conditionController.text,
                                              );
                                            });
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text("Add"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24),

                            // Allergies Section
                            Text(
                              "Allergies",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (String allergy in localAllergies)
                                  Chip(
                                    label: Text(allergy),
                                    backgroundColor: Color(0xFFE0F7FA),
                                    deleteIconColor: Colors.grey,
                                    onDeleted: () {
                                      setState(() {
                                        localAllergies.remove(allergy);
                                      });
                                    },
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: Icon(Icons.add, color: Color(0xFF33D4C8)),
                              label: Text(
                                "Add Allergy",
                                style: TextStyle(color: Color(0xFF33D4C8)),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Color(0xFF33D4C8),
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Color(0xFF33D4C8)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                TextEditingController allergyController =
                                TextEditingController();
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                    title: Text("Add Allergy"),
                                    content: TextField(
                                      controller: allergyController,
                                      decoration: InputDecoration(
                                        hintText: "Enter allergy name",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (allergyController
                                              .text
                                              .isNotEmpty) {
                                            setState(() {
                                              localAllergies.add(
                                                allergyController.text,
                                              );
                                            });
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text("Add"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24),

                            // Current Medications Section
                            Text(
                              "Current Medications (Optional)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: localMedicationController,
                                decoration: InputDecoration(
                                  hintText: "e.g.: Metformin, Inhaler",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF33D4C8),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Save the changes
                          this.setState(() {
                            medicalConditions = List.from(
                              localMedicalConditions,
                            );
                            allergies = List.from(localAllergies);
                            weightController.text = localWeightController.text;
                            heightController.text = localHeightController.text;
                            medicationController.text =
                                localMedicationController.text;
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Medical data changes have been applied",
                              ),
                              backgroundColor: Color(0xFF33D4C8),
                            ),
                          );
                        },
                        child: Text(
                          "Apply Changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF33D4C8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Color(0xFF33D4C8), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF33D4C8)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF33D4C8)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountSettingsPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33D4C8)),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildProfileImage(),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF33D4C8),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildMenuButton(
                    icon: Icons.person,
                    title: "Edit My Profile",
                    onTap: _showEditMedicalDataDialog,
                  ),
                  const Divider(height: 1),
                  _buildMenuButton(
                    icon: Icons.notifications,
                    title: "Notification",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrafficAlertsPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuButton(
                    icon: Icons.calendar_today,
                    title: "My Schedule",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SchedulePage()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuButton(
                    icon: Icons.info,
                    title: "About MediTrack",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuButton(
                    icon: Icons.help,
                    title: "Help & Support",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpSupportPage(),
                        ),
                      );
                    },
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
            // Navigate to HomePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
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
}