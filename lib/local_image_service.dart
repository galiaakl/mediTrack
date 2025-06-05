import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class LocalImageService {
  static const String _profileImageKey = 'profile_image_path';

  // Save image to local storage
  static Future<bool> saveProfileImage(File imageFile) async {
    try {
      // Get the app document directory
      final appDir = await getApplicationDocumentsDirectory();

      // Create a unique filename with timestamp
      final fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localPath = '${appDir.path}/$fileName';

      // Copy the image file to the app directory
      await imageFile.copy(localPath);

      // Save the path in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImageKey, localPath);

      print('Image saved locally: $localPath');
      return true;
    } catch (e) {
      print('Error saving image locally: $e');
      return false;
    }
  }

  // Get the profile image as a File
  static Future<File?> getProfileImageFile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_profileImageKey);

      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          print('Local image found: $imagePath');
          return file;
        } else {
          print('Image file no longer exists: $imagePath');
          return null;
        }
      } else {
        print('No local image path saved');
        return null;
      }
    } catch (e) {
      print('Error getting local image: $e');
      return null;
    }
  }

  // Get the profile image as an ImageProvider
  static Future<ImageProvider?> getProfileImage() async {
    try {
      final file = await getProfileImageFile();
      if (file != null) {
        return FileImage(file);
      }
      return null;
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }

  // Check if a profile image exists
  static Future<bool> hasProfileImage() async {
    final file = await getProfileImageFile();
    return file != null;
  }

  // Clear the saved profile image
  static Future<bool> clearProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_profileImageKey);

      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await prefs.remove(_profileImageKey);
      print('Profile image cleared');
      return true;
    } catch (e) {
      print('Error clearing profile image: $e');
      return false;
    }
  }
}