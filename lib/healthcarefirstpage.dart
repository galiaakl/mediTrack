import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditrack_new/healthcaresecondpage.dart';
import 'package:meditrack_new/image_selector.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'local_image_service.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  // Selected profile image
  File? _profileImage;
  bool _isUploading = false;
  bool _isLoading = true;

  // Image data
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load existing user data if available
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Get user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('healthcare_providers')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          // Set form data
          setState(() {
            String fullName = userData['displayName'] ?? '';
            // Remove "Dr. " prefix if present
            if (fullName.startsWith('Dr. ')) {
              fullName = fullName.substring(4);
            }

            List<String> nameParts = fullName.split(' ');
            if (nameParts.isNotEmpty) {
              firstNameController.text = nameParts[0];
              if (nameParts.length > 1) {
                lastNameController.text = nameParts.sublist(1).join(' ');
              }
            }

            // Load base64 image if available
            if (userData['imageBase64'] != null) {
              _base64Image = userData['imageBase64'];
            }
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to update profile picture
  Future<void> _onProfilePictureTap() async {
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
        });

        // Get current user
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('No user is currently logged in');
        }

        // Save as base64 in Firestore
        await _saveImageAsBase64(_profileImage!, currentUser.uid);

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

      // Save the base64 data to Firestore in both collections
      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(
          FirebaseFirestore.instance.collection('healthcare_providers').doc(userId),
          {'imageBase64': base64Image}
      );

      batch.update(
          FirebaseFirestore.instance.collection('users').doc(userId),
          {'imageBase64': base64Image}
      );

      await batch.commit();

      // Update local state
      setState(() {
        _base64Image = base64Image;
      });
    } catch (e) {
      print('Error storing image as base64: $e');
      throw e;
    }
  }

  // Save profile and continue
  Future<void> _saveProfileAndContinue() async {
    // Check if form fields are filled
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (_profileImage != null) {
      print('Saving profile image...');
      bool success = await LocalImageService.saveProfileImage(_profileImage!);
      if (success) {
        print('Profile image saved successfully');
      } else {
        print('Failed to save profile image');
      }
    } else {
      print('No profile image to save');
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      // Create user data
      Map<String, dynamic> userData = {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'displayName': '${firstNameController.text} ${lastNameController.text}',
        'name': 'Dr. ${firstNameController.text} ${lastNameController.text}', // Include "Dr." prefix for healthcare professionals
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update user profile in Firebase Auth
      await currentUser.updateDisplayName('Dr. ${firstNameController.text} ${lastNameController.text}');

      // If we have selected a profile image, save it
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Check size - Firestore has a 1MB document limit
        if (base64Image.length > 500000) {
          throw Exception('Image too large. Please select a smaller image.');
        }

        userData['imageBase64'] = base64Image;

        print("Saving healthcare image with length: ${base64Image.length}");
      }

      // Save to Firestore in both collections
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Check if documents already exist
      DocumentSnapshot hcpDoc = await FirebaseFirestore.instance
          .collection('healthcare_providers')
          .doc(currentUser.uid)
          .get();

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Update or create healthcare_providers document
      if (hcpDoc.exists) {
        batch.update(
            FirebaseFirestore.instance.collection('healthcare_providers').doc(currentUser.uid),
            userData
        );
      } else {
        batch.set(
            FirebaseFirestore.instance.collection('healthcare_providers').doc(currentUser.uid),
            userData,
            SetOptions(merge: true)
        );
      }

      // Update or create users document
      if (userDoc.exists) {
        batch.update(
            FirebaseFirestore.instance.collection('users').doc(currentUser.uid),
            userData
        );
      } else {
        batch.set(
            FirebaseFirestore.instance.collection('users').doc(currentUser.uid),
            userData,
            SetOptions(merge: true)
        );
      }

      await batch.commit();

      // Navigate to next page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfessionalInfoPage(),
        ),
      );
    } catch (e) {
      print('Error saving profile: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Healthcare Professional',
          style: TextStyle(color: Colors.white),
        ),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Profile Image
                  GestureDetector(
                    onTap: _isUploading ? null : _onProfilePictureTap,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            // Profile image with various sources
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Color(0xFFE0E0E0),
                              backgroundImage: _getProfileImage(),
                              child: (_profileImage == null && _base64Image == null)
                                  ? Icon(Icons.person, size: 50, color: Colors.grey)
                                  : null,
                            ),
                            // Edit icon overlay
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF33D4C8),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Update profile picture',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // First Name
                  _buildTextField(
                    label: 'First Name',
                    hintText: 'Enter your first name',
                    controller: firstNameController,
                  ),

                  const SizedBox(height: 16),

                  // Last Name
                  _buildTextField(
                    label: 'Last Name',
                    hintText: 'Enter your last name',
                    controller: lastNameController,
                  ),

                  const SizedBox(height: 16),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _saveProfileAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF33D4C8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Color(0xFF33D4C8).withOpacity(0.5),
                      ),
                      child: _isUploading
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Full screen loading overlay
          if (_isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33D4C8)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Get profile image from various sources
  ImageProvider? _getProfileImage() {
    // New selected image takes priority
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }

    // Then check for base64 image
    if (_base64Image != null) {
      try {
        final bytes = base64Decode(_base64Image!);
        return MemoryImage(Uint8List.fromList(bytes));
      } catch (e) {
        print('Error decoding base64 image: $e');
      }
    }

    // No image found
    return null;
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}