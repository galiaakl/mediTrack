// File: lib/services/email_service.dart
import 'package:flutter/foundation.dart';

class EmailService {
  // Development mode email "service" that just prints codes to console
  static Future<bool> sendVerificationEmail({
    required String to,
    required String name,
    required String code,
  }) async {
    try {
      // Print the verification code with a distinct pattern to find it easily
      print('\n');
      print('📧 ============ VERIFICATION EMAIL ============ 📧');
      print('📧 TO: $to');
      print('📧 NAME: $name');
      print('📧 CODE: $code');
      print('📧 =========================================== 📧');
      print('\n');

      // In a real app, you would actually send an email here
      // But for development, we just return true as if the email was sent
      return true;
    } catch (e) {
      print('Error in development email service: $e');
      return false;
    }
  }

  // Similarly for password reset
  static Future<bool> sendPasswordResetEmail({
    required String to,
    required String code,
  }) async {
    try {
      print('\n');
      print('🔑 ============ PASSWORD RESET EMAIL ============ 🔑');
      print('🔑 TO: $to');
      print('🔑 CODE: $code');
      print('🔑 ============================================== 🔑');
      print('\n');

      return true;
    } catch (e) {
      print('Error in development password reset service: $e');
      return false;
    }
  }
}