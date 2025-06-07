import 'package:flutter/material.dart';
import 'package:meditrack_new/screens/profile_setup/regularusersecondpage.dart';
import 'package:meditrack_new/services/image_selector.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/local_image_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegularUserProfilePage extends StatefulWidget {
  const RegularUserProfilePage({super.key});

  @override
  State<RegularUserProfilePage> createState() => _RegularUserProfilePageState();
}

class _RegularUserProfilePageState extends State<RegularUserProfilePage> {
  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

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
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          // Set form data
          setState(() {
            _firstNameController.text = userData['firstName'] ?? '';
            _lastNameController.text = userData['lastName'] ?? '';

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

      // Save the base64 data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'imageBase64': base64Image});

      // Update local state
      setState(() {
        _base64Image = base64Image;
      });
    } catch (e) {
      print('Error storing image as base64: $e');
      throw e;
    }
  }

  // Save user profile and continue
  Future<void> _saveProfileAndContinue() async {
    // Check if form fields are filled
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a map with user data (for SharedPreferences)
      Map<String, String> userData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'displayName': '${_firstNameController.text} ${_lastNameController.text}',
      };

      // Save user data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(userData));

      print('User data saved: $userData');

      // Save profile image if selected
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

      // Navigate to next page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HealthProfilePage(),
        ),
      );
    } catch (e) {
      print('Error saving profile: $e');
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF33D4C8),
        elevation: 0,
        title: const Text(
          'Regular User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // Profile Picture
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _isUploading ? null : _updateProfilePicture,
                        child: Stack(
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
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Update profile picture',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // First Name Field
                  _buildTextField(
                    label: 'First Name',
                    hintText: 'Enter your first name',
                    controller: _firstNameController,
                  ),

                  const SizedBox(height: 15),

                  // Last Name Field
                  _buildTextField(
                    label: 'Last Name',
                    hintText: 'Enter your last name',
                    controller: _lastNameController,
                  ),

                  const SizedBox(height: 15),

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

  // TextField builder
  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }
}