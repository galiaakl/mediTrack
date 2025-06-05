// File: lib/services/verification_manager.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fixed verification code - will always be accepted for testing
  static const String FIXED_CODE = "1906";

  // Generate a 4-digit verification code (still generating random, but fixed code will work)
  static String generateVerificationCode() {
    return (1000 + Random().nextInt(9000)).toString();
  }

  // Store verification code in Firestore
  static Future<void> storeVerificationCode(String uid, String code) async {
    try {
      await _firestore.collection('verification_codes').doc(uid).set({
        'code': code,
        'createdAt': FieldValue.serverTimestamp(),
        'verified': false,
      });

      // Print for development purposes
      print("Stored verification code: $code for user: $uid");
      print("Note: The fixed code 1906 will also work for verification");
    } catch (e) {
      print('Error storing verification code: $e');
      throw e;
    }
  }

  // Verify the code entered by user
  static Future<bool> verifyCode(String uid, String enteredCode) async {
    try {
      // Always accept the fixed code
      if (enteredCode == FIXED_CODE) {
        print("✅ Using fixed verification code: $FIXED_CODE");

        // Update verification status in all collections
        await updateVerificationStatus(uid);
        return true;
      }

      // Otherwise check the stored code (regular flow)
      final docSnapshot = await _firestore.collection('verification_codes').doc(uid).get();

      if (!docSnapshot.exists) {
        print("No verification code found for user: $uid");
        return false;
      }

      final data = docSnapshot.data()!;
      final storedCode = data['code'] as String;
      final timestamp = (data['createdAt'] as Timestamp).toDate();

      // Check if code is expired (10 minutes)
      final now = DateTime.now();
      final difference = now.difference(timestamp);
      if (difference.inMinutes > 10) {
        print("Verification code expired for user: $uid");
        return false;
      }

      // Check if code matches
      if (storedCode == enteredCode) {
        // Update verification status in all collections
        await updateVerificationStatus(uid);
        return true;
      }

      print("Invalid verification code entered: $enteredCode (expected: $storedCode)");
      return false;
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }

  // Update verification status in all relevant collections
  static Future<void> updateVerificationStatus(String uid) async {
    try {
      final batch = _firestore.batch();

      // Update verification_codes collection
      batch.update(_firestore.collection('verification_codes').doc(uid), {
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      // Update main users collection
      batch.update(_firestore.collection('users').doc(uid), {
        'isVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      // Get the user role to update the appropriate role-specific collection
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final userRole = userData['userRole'] as String?;

        if (userRole == 'healthcare') {
          batch.update(_firestore.collection('healthcare_providers').doc(uid), {
            'isVerified': true,
            'verifiedAt': FieldValue.serverTimestamp(),
          });
        } else if (userRole == 'regular') {
          batch.update(_firestore.collection('regular_users').doc(uid), {
            'isVerified': true,
            'verifiedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      print("User verification status updated in all collections for uid: $uid");
    } catch (e) {
      print('Error updating verification status: $e');
      throw e;
    }
  }

  // Resend verification code
  static Future<String> resendVerificationCode(String uid) async {
    // Generate a new code
    final code = generateVerificationCode();

    // Store the new code
    await storeVerificationCode(uid, code);

    print("Resent verification code: $code for user: $uid");
    print("Note: The fixed code 1906 will also work for verification");

    return code;
  }

  // Check if user is verified
  static Future<bool> isUserVerified(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (!docSnapshot.exists) {
        return false;
      }

      return docSnapshot.data()?['isVerified'] ?? false;
    } catch (e) {
      print('Error checking verification status: $e');
      return false;
    }
  }
}