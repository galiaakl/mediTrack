// File: lib/image_selector.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageSelector {
  static final ImagePicker _picker = ImagePicker();

  // Pick an image from gallery (Google Photos in the emulator)
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Adjust image quality (0-100)
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Simple function to directly open gallery without showing a dialog
  static Future<File?> selectImage() async {
    return await pickImageFromGallery();
  }
}