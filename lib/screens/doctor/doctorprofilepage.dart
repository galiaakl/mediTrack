import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditrack_new/services/auth_service.dart';
import 'package:meditrack_new/services/image_selector.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../user/accountsettings.dart';
import 'package:meditrack_new/screens/support/helpandsupport.dart';
import '../support/about.dart';
import '../profile_setup/regularuserfirstpage.dart';
import 'package:meditrack_new/screens/auth/login_healthcare.dart';
import '../../services/local_image_service.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({Key? key}) : super(key: key);

  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  String userName = "Doctor";
  ImageProvider? userProfileImage;
  bool _isLoading = true;
  String? userId;
  String? localImagePath;
  File? _profileImage;
  bool _isUploading = false;
  String? _base64Image;

  // Practice details
  final clinicNameController = TextEditingController();
  final workAddressController = TextEditingController();
  bool offerOnlineBooking = false;
  final clinicEmailController = TextEditingController();
  List<String> languages = ["Arabic", "English"];
  String? specialty;

  // Availability
  Set<String> selectedDays = {"W", "F", "Sa"};
  Map<String, Map<String, String>> availableHours = {
    "W": {"from": "9:00 AM", "to": "5:00 PM"},
    "F": {"from": "9:00 AM", "to": "5:00 PM"},
    "Sa": {"from": "9:00 AM", "to": "5:00 PM"},
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    clinicNameController.dispose();
    workAddressController.dispose();
    clinicEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      userId = currentUser.uid;

      print("Loading doctor profile for user: $userId");

      // Get user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('healthcare_providers')
          .doc(userId)
          .get();

      print("Healthcare provider doc exists: ${userDoc.exists}");

      if (!userDoc.exists) {
        // Try to get from main users collection
        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        print("User doc exists: ${userDoc.exists}");
      }

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          // Set user name
          userName = userData['name'] ??
              userData['displayName'] ??
              "Dr. " + (currentUser.displayName ?? 'User');

          print("Checking for imageBase64 in document...");

          // Set user photo - check for base64 image first
          if (userData['imageBase64'] != null) {
            try {
              print("Found imageBase64 with length: ${userData['imageBase64'].length}");
              _base64Image = userData['imageBase64'];
              final bytes = base64Decode(_base64Image!);
              userProfileImage = MemoryImage(Uint8List.fromList(bytes));
              print("Successfully loaded doctor profile image");
            } catch (e) {
              print('Error decoding base64 image: $e');
            }
          } else {
            print("No imageBase64 found in document");
          }

          // Set clinic details if available
          clinicNameController.text = userData['clinicName'] ?? '';
          workAddressController.text = userData['workAddress'] ?? '';
          offerOnlineBooking = userData['offerOnlineBooking'] ?? false;
          clinicEmailController.text = userData['clinicEmail'] ?? '';

          // Set specialty
          specialty = userData['specialty'] ?? '';

          // Set languages if available
          if (userData.containsKey('languages') && userData['languages'] is List) {
            languages = List<String>.from(userData['languages']);
          }

          // Set availability if available
          if (userData.containsKey('selectedDays') && userData['selectedDays'] is List) {
            selectedDays = Set<String>.from(userData['selectedDays']);
          }

          if (userData.containsKey('availableHours') && userData['availableHours'] is Map) {
            availableHours = Map<String, Map<String, String>>.from(
                (userData['availableHours'] as Map).map((key, value) =>
                    MapEntry(key.toString(), Map<String, String>.from(value))
                )
            );
          }
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    try {
      if (userId == null) {
        throw Exception('User ID is null');
      }

      // Create data to update
      Map<String, dynamic> userData = {
        'clinicName': clinicNameController.text,
        'workAddress': workAddressController.text,
        'offerOnlineBooking': offerOnlineBooking,
        'clinicEmail': clinicEmailController.text,
        'languages': languages,
        'selectedDays': selectedDays.toList(),
        'availableHours': availableHours,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // If specialty is set, add it to the update
      if (specialty != null && specialty!.isNotEmpty) {
        userData['specialty'] = specialty;
      }

      // Update in Firestore - both collections
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Update healthcare_providers collection
      batch.update(
          FirebaseFirestore.instance.collection('healthcare_providers').doc(userId),
          userData
      );

      // Also update main users collection
      batch.update(
          FirebaseFirestore.instance.collection('users').doc(userId),
          userData
      );

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile data updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onEditProfilePicture() async {
    try {
      // Open gallery to select image
      File? imageFile = await ImageSelector.selectImage();

      if (imageFile != null) {
        setState(() {
          _isLoading = true;
        });

        // Save the image using LocalImageService
        bool success = await LocalImageService.saveProfileImage(imageFile);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile picture updated successfully'),
                backgroundColor: Colors.green,
              )
          );

          // Force a rebuild to show the new image
          setState(() {});
        } else {
          throw Exception('Failed to save profile image');
        }
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set profile picture: $e'),
            backgroundColor: Colors.red,
          )
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileImage() {
    return FutureBuilder<ImageProvider?>(
        future: LocalImageService.getProfileImage(),
        builder: (context, snapshot) {
          return Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE0E0E0),
                backgroundImage: snapshot.data,
                child: snapshot.data == null
                    ? Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'D',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: _onEditProfilePicture,
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
    );
  }

  void _showEditPracticeDetailsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
      TextEditingController localClinicNameController = TextEditingController(
        text: clinicNameController.text,
      );
      TextEditingController localWorkAddressController =
      TextEditingController(text: workAddressController.text);
      TextEditingController localClinicEmailController =
      TextEditingController(text: clinicEmailController.text);
      TextEditingController specialtyController = TextEditingController(
        text: specialty ?? '',
      );
      bool localOfferOnlineBooking = offerOnlineBooking;
      Set<String> localSelectedDays = Set.from(selectedDays);
      Map<String, Map<String, String>> localAvailableHours = Map.from(
        availableHours,
      );
      List<String> localLanguages = List.from(languages);

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
                "Your Practice Details",
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
    Center(
    child: Text(
    "Choose where you consult and\nwhen you're available",
    textAlign: TextAlign.center,
    style: TextStyle(
    color: Colors.grey,
    fontSize: 14,
    ),
    ),
    ),
    SizedBox(height: 20),

    // Specialty Section (NEW)
    Text(
    "Medical Specialty",
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    ),
    ),
    SizedBox(height: 8),
    Container(
    decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(8),
    ),
    child: TextField(
    controller: specialtyController,
    decoration: InputDecoration(
    hintText: "e.g. Cardiology, Pediatrics",
    contentPadding: EdgeInsets.symmetric(
    horizontal: 12,
    ),
    border: InputBorder.none,
    ),
    ),
    ),
    SizedBox(height: 20),

    // Clinic/Hospital Name Section
    Text(
    "Clinic / Hospital Name (Optional)",
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    ),
    ),
    SizedBox(height: 8),
    Container(
    decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(8),
    ),
    child: TextField(
    controller: localClinicNameController,
    decoration: InputDecoration(
    hintText: "Enter clinic or hospital name",
    contentPadding: EdgeInsets.symmetric(
    horizontal: 12,
    ),
    border: InputBorder.none,
    ),
    ),
    ),
    SizedBox(height: 20),

    // Work Address Section
    Text(
    "Work Address",
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    ),
    ),
    SizedBox(height: 8),
    Container(
    decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(8),
    ),
    child: TextField(
    controller: localWorkAddressController,
    decoration: InputDecoration(
    hintText: "Enter work address",
    contentPadding: EdgeInsets.symmetric(
    horizontal: 12,
    ),
    border: InputBorder.none,
    ),
    ),
    ),
    SizedBox(height: 20),

    // Availability Section
    Text(
    "Availability",
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    ),
    ),
    SizedBox(height: 8),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    _buildDaySelector(
    'M',
    localSelectedDays,
    setState,
    ),
    _buildDaySelector(
    'Tu', // Changed from 'T' to 'Tu' for Tuesday
    localSelectedDays,
    setState,
    ),
    _buildDaySelector(
    'W',
    localSelectedDays,
    setState,
    ),
    _buildDaySelector(
    'Th', // Changed from 'T' to 'Th' for Thursday
    localSelectedDays,
    setState,
    ),
    _buildDaySelector(
    'F',
    localSelectedDays,
    setState,
    ),
    _buildDaySelector(
    'Sa', // Changed from 'S' to 'Sa' for Saturday
    localSelectedDays,
    setState,
    ),
    _buildDaySelector(
    'Su', // Changed from 'S' to 'Su' for Sunday
      localSelectedDays,
      setState,
    ),
    ],
    ),
      SizedBox(height: 20),

      // Show time slots for selected days
      for (String day in localSelectedDays)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$day - Available Hours",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            _buildTimeSelectors(
              day,
              localAvailableHours,
              setState,
            ),
            SizedBox(height: 16),
          ],
        ),

      // Online Consultation Section
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Offer Online Booking?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: localOfferOnlineBooking,
            onChanged: (value) {
              setState(() {
                localOfferOnlineBooking = value;
              });
            },
            activeColor: Color(0xFF33D4C8),
          ),
        ],
      ),

      // Online Booking Email Field
      if (localOfferOnlineBooking)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              "Clinic Email Address",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(
                    255,
                    106,
                    106,
                    106,
                  ),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: localClinicEmailController,
                decoration: InputDecoration(
                  hintText: "Enter clinic email",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Online bookings will be sent to this email",
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ],
        ),

      SizedBox(height: 20),

      // Languages Section
      Text(
        "Languages Spoken",
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
          for (String language in localLanguages)
            Chip(
              label: Text(language),
              backgroundColor: Colors.grey.shade200,
              deleteIconColor: Colors.grey,
              onDeleted: () {
                setState(() {
                  localLanguages.remove(language);
                });
              },
            ),
          OutlinedButton.icon(
            icon: Icon(
              Icons.add,
              size: 18,
              color: Color(0xFF33D4C8),
            ),
            label: Text("Add"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFF33D4C8),
              side: BorderSide(color: Color(0xFF33D4C8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              TextEditingController languageController =
              TextEditingController();
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                  title: Text("Add Language"),
                  content: TextField(
                    controller: languageController,
                    decoration: InputDecoration(
                      hintText: "Enter language name",
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          () =>
                          Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        if (languageController
                            .text
                            .isNotEmpty) {
                          setState(() {
                            localLanguages.add(
                              languageController.text,
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
        ],
      ),
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
                          this.setState(() {
                            clinicNameController.text =
                                localClinicNameController.text;
                            workAddressController.text =
                                localWorkAddressController.text;
                            clinicEmailController.text =
                                localClinicEmailController.text;
                            offerOnlineBooking = localOfferOnlineBooking;
                            selectedDays = Set.from(localSelectedDays);
                            availableHours = Map.from(localAvailableHours);
                            languages = List.from(localLanguages);
                            specialty = specialtyController.text;
                          });
                          Navigator.pop(context);

                          // Save changes to Firestore
                          _saveUserData();
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

  Widget _buildDaySelector(
      String day,
      Set<String> localSelectedDays,
      StateSetter setState,
      ) {
    bool isSelected = localSelectedDays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            localSelectedDays.remove(day);
            if (availableHours.containsKey(day)) {
              availableHours.remove(day);
            }
          } else {
            localSelectedDays.add(day);
            if (!availableHours.containsKey(day)) {
              availableHours[day] = {"from": "9:00 AM", "to": "5:00 PM"};
            }
          }
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Color(0xFF33D4C8) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xFF33D4C8) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            day.length > 1 ? day.substring(0, 1) : day,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelectors(
      String day,
      Map<String, Map<String, String>> localAvailableHours,
      StateSetter setState,
      ) {
    // Initialize if not already present
    if (!localAvailableHours.containsKey(day)) {
      localAvailableHours[day] = {"from": "9:00 AM", "to": "5:00 PM"};
    }

    return Column(
      children: [
        Row(
          children: [
            Text("From:"),
            SizedBox(width: 8),
            _buildTimeDropdown(
              value: localAvailableHours[day]!["from"]!.split(":")[0],
              items: List.generate(12, (index) => (index + 1).toString()),
              onChanged: (value) {
                setState(() {
                  String minute =
                  localAvailableHours[day]!["from"]!.split(":")[1];
                  localAvailableHours[day]!["from"] = "$value:$minute";
                });
              },
            ),
            Text(" : "),
            _buildTimeDropdown(
              value:
              localAvailableHours[day]!["from"]!
                  .split(":")[1]
                  .split(" ")[0],
              items: ["00", "15", "30", "45"],
              onChanged: (value) {
                setState(() {
                  String hour =
                  localAvailableHours[day]!["from"]!.split(":")[0];
                  String period =
                  localAvailableHours[day]!["from"]!.contains("PM")
                      ? "PM"
                      : "AM";
                  localAvailableHours[day]!["from"] = "$hour:$value $period";
                });
              },
            ),
            SizedBox(width: 8),
            _buildTimeDropdown(
              value:
              localAvailableHours[day]!["from"]!.contains("PM")
                  ? "PM"
                  : "AM",
              items: ["AM", "PM"],
              onChanged: (value) {
                setState(() {
                  String time =
                  localAvailableHours[day]!["from"]!.split(" ")[0];
                  localAvailableHours[day]!["from"] = "$time $value";
                });
              },
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text("To:"),
            SizedBox(width: 20),
            _buildTimeDropdown(
              value: localAvailableHours[day]!["to"]!.split(":")[0],
              items: List.generate(12, (index) => (index + 1).toString()),
              onChanged: (value) {
                setState(() {
                  String minute =
                  localAvailableHours[day]!["to"]!.split(":")[1];
                  localAvailableHours[day]!["to"] = "$value:$minute";
                });
              },
            ),
            Text(" : "),
            _buildTimeDropdown(
              value:
              localAvailableHours[day]!["to"]!.split(":")[1].split(" ")[0],
              items: ["00", "15", "30", "45"],
              onChanged: (value) {
                setState(() {
                  String hour = localAvailableHours[day]!["to"]!.split(":")[0];
                  String period =
                  localAvailableHours[day]!["to"]!.contains("PM")
                      ? "PM"
                      : "AM";
                  localAvailableHours[day]!["to"] = "$hour:$value $period";
                });
              },
            ),
            SizedBox(width: 8),
            _buildTimeDropdown(
              value:
              localAvailableHours[day]!["to"]!.contains("PM") ? "PM" : "AM",
              items: ["AM", "PM"],
              onChanged: (value) {
                setState(() {
                  String time = localAvailableHours[day]!["to"]!.split(" ")[0];
                  localAvailableHours[day]!["to"] = "$time $value";
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeDropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items:
          items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  // Sign out function
  Future<void> _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HealthcareLoginPage()),
            (route) => false, // Remove all previous routes
      );
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  // Show sign out confirmation dialog
  Future<void> _showSignOutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to sign out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
            ),
          ],
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

                  // Display specialty if available
                  if (specialty != null && specialty!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        specialty!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),
                  _buildMenuButton(
                    icon: Icons.business,
                    title: "Your Practice Details",
                    onTap: _showEditPracticeDetailsDialog,
                  ),
                  const Divider(height: 1),
                  _buildMenuButton(
                    icon: Icons.person,
                    title: "Switch to Regular User",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegularUserProfilePage(),
                        ),
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
                  const Divider(height: 1),
                  // Sign Out button
                  _buildMenuButton(
                    icon: Icons.exit_to_app,
                    title: "Sign Out",
                    onTap: _showSignOutConfirmation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}