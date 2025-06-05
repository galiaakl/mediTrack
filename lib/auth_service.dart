// File: lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:meditrack_new/email_service.dart';
import 'package:meditrack_new/verification_manager.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  String? _verificationId;

  // Getters
  AuthStatus get status => _status;

  User? get user => _user;

  String? get errorMessage => _errorMessage;

  String? get verificationId => _verificationId;

  AuthService() {
    // Listen to authentication state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _status =
      user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  // Generate a 4-digit verification code
  String _generateVerificationCode() {
    return VerificationManager.generateVerificationCode();
  }

  bool isValidEmail(String email) {
    RegExp emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Save user credentials for auto-login
  Future<void> saveUserCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setBool('autoLogin', true);
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  // Clear saved credentials (e.g., on logout)
  Future<void> clearUserCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('autoLogin', false);
    } catch (e) {
      print('Error clearing credentials: $e');
    }
  }

  // Check if auto-login is enabled
  Future<bool> isAutoLoginEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('autoLogin') ?? false;
    } catch (e) {
      print('Error checking auto-login: $e');
      return false;
    }
  }

  // Auto login with saved credentials
  Future<UserCredential?> autoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      final password = prefs.getString('password');

      if (email != null && password != null) {
        return await signInWithEmailAndPassword(
            email: email, password: password);
      }
      return null;
    } catch (e) {
      print('Auto-login failed: $e');
      return null;
    }
  }

  // Create a new user with email and password
  Future<Map<String, dynamic>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String mobileNumber,
    required String countryCode,
    required String userRole,
    String? name,
    String? specialty,
    String? licenseNumber,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      // Normalize email
      final normalizedEmail = email.trim().toLowerCase();

      // Check if email exists in the other role collection
      final oppositeRole = userRole == 'healthcare' ? 'regular' : 'healthcare';
      final existingUsers = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .where('userRole', isEqualTo: oppositeRole)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        throw FirebaseAuthException(
            code: 'role-conflict',
            message: userRole == 'healthcare'
                ? 'This email is already registered as a regular user'
                : 'This email is already registered as a healthcare provider'
        );
      }

      // Generate a verification code
      final String verificationCode = _generateVerificationCode();

      // Debug output
      print(
          "Generated verification code: $verificationCode for email: $normalizedEmail");

      // Create user with Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      // Generate a unique ID for healthcare professionals
      String? professionalId;
      if (userRole == 'healthcare') {
        professionalId = 'HC-${DateTime
            .now()
            .millisecondsSinceEpoch
            .toString()
            .substring(7)}';
      }

      // Store additional user data in Firestore including verification code
      await _storeUserData(
        uid: userCredential.user!.uid,
        email: normalizedEmail,
        mobileNumber: mobileNumber,
        countryCode: countryCode,
        userRole: userRole,
        verificationCode: verificationCode,
        name: name,
        specialty: specialty,
        licenseNumber: licenseNumber,
        professionalId: professionalId,
      );

      // Store verification code in dedicated collection
      await VerificationManager.storeVerificationCode(
        userCredential.user!.uid,
        verificationCode,
      );

      // Use our development email service to display code
      await EmailService.sendVerificationEmail(
        to: normalizedEmail,
        name: name ?? '',
        code: verificationCode,
      );

      // Successfully created user
      return {
        'user': userCredential.user,
        'verificationCode': verificationCode,
        'professionalId': professionalId,
      };
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getFirebaseAuthErrorMessage(e.code);
      print("Firebase Auth Exception: ${e.code} - ${_errorMessage}");
      notifyListeners();
      return {'error': _errorMessage};
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      print("Error in createUserWithEmailAndPassword: $e");
      notifyListeners();
      return {'error': _errorMessage};
    }
  }

  // Store user data in Firestore
  Future<void> _storeUserData({
    required String uid,
    required String email,
    required String mobileNumber,
    required String countryCode,
    required String userRole,
    required String verificationCode,
    String? name,
    String? specialty,
    String? licenseNumber,
    String? professionalId,
  }) async {
    try {
      final Map<String, dynamic> userData = {
        'email': email,
        'mobileNumber': mobileNumber,
        'countryCode': countryCode,
        'userRole': userRole,
        'verificationCode': verificationCode,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
      };

      // Add healthcare professional specific fields
      if (userRole == 'healthcare') {
        userData['name'] = name ?? '';
        userData['specialty'] = specialty ?? '';
        userData['licenseNumber'] = licenseNumber ?? '';
        userData['professionalId'] = professionalId;
        userData['isApproved'] = false; // Healthcare providers need approval
      } else {
        userData['name'] = name ?? '';
      }

      // Create batch to update multiple collections
      final batch = _firestore.batch();

      // Store in main users collection
      batch.set(_firestore.collection('users').doc(uid), userData);

      // Store in role-specific collection
      if (userRole == 'healthcare') {
        batch.set(
            _firestore.collection('healthcare_providers').doc(uid), userData);
      } else {
        batch.set(_firestore.collection('regular_users').doc(uid), userData);
      }

      await batch.commit();

      print("User data stored in Firestore for uid: $uid");
    } catch (e) {
      print("Error storing user data in Firestore: $e");
      throw e;
    }
  }

  // Verify code entered by user
  Future<bool> verifyCode(String enteredCode) async {
    if (_auth.currentUser == null) {
      print("No current user to verify code");
      return false;
    }

    try {
      return await VerificationManager.verifyCode(
          _auth.currentUser!.uid, enteredCode);
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    if (_auth.currentUser == null) {
      return false;
    }

    try {
      // First, reload the user to get the latest status
      await _auth.currentUser!.reload();

      // Check Firebase native verification status
      if (_auth.currentUser!.emailVerified) {
        // If Firebase shows verified, update our Firestore record
        await updateVerificationStatus();
        return true;
      }

      // Check in Firestore if the custom verification was completed
      final docSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (!docSnapshot.exists) {
        return false;
      }

      return docSnapshot.data()?['isVerified'] ?? false;
    } catch (e) {
      print('Error checking verification status: $e');
      return false;
    }
  }

  // Sign in existing user with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      // Normalize email
      final normalizedEmail = email.trim().toLowerCase();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      // Save credentials for auto-login if successful
      await saveUserCredentials(normalizedEmail, password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getFirebaseAuthErrorMessage(e.code);
      notifyListeners();
      return null;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Send password reset email using Firebase's built-in functionality
  Future<bool> sendPasswordResetLink(String email) async {
    try {
      // Normalize email address by trimming and converting to lowercase
      final normalizedEmail = email.trim().toLowerCase();

      // Debug output - print both original and normalized email
      print('📧 Attempting to send password reset to:');
      print('   Original: "$email"');
      print('   Normalized: "$normalizedEmail"');

      // Try to directly send the reset email without checking first
      await _auth.sendPasswordResetEmail(email: normalizedEmail);

      print('✅ Password reset email sent directly to: $normalizedEmail');
      return true;
    } on FirebaseAuthException catch (e) {
      // More detailed error logging
      _errorMessage = _getFirebaseAuthErrorMessage(e.code);
      print('❌ Firebase Auth Exception Details:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');

      // Additional logging for user-not-found
      if (e.code == 'user-not-found') {
        print(
            '🔍 User not found, attempting to list all users in Firebase Auth:');
        try {
          // Try to list all users from Firestore as a debugging step
          final usersSnapshot = await _firestore.collection('users').get();
          print('   Found ${usersSnapshot.docs.length} users in Firestore:');

          for (var doc in usersSnapshot.docs) {
            final userData = doc.data();
            print('   - ${userData['email']} (${doc.id})');
          }
        } catch (listError) {
          print('   Error listing users: $listError');
        }
      }

      return false;
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ General Error: $e');
      return false;
    }
  }

  // Update user verification status in Firestore
  Future<void> updateVerificationStatus() async {
    if (_auth.currentUser != null) {
      final batch = _firestore.batch();
      final userId = _auth.currentUser!.uid;

      // Get the user data to determine their role
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final userRole = userData['userRole'] as String?;

        // Update main users collection
        batch.update(_firestore.collection('users').doc(userId), {
          'isVerified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
        });

        // Update role-specific collection if available
        if (userRole == 'healthcare') {
          batch.update(
              _firestore.collection('healthcare_providers').doc(userId), {
            'isVerified': true,
            'verifiedAt': FieldValue.serverTimestamp(),
          });
        } else if (userRole == 'regular') {
          batch.update(_firestore.collection('regular_users').doc(userId), {
            'isVerified': true,
            'verifiedAt': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await clearUserCredentials(); // Clear auto-login credentials
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Get user role (healthcare or regular)
  Future<String?> getUserRole() async {
    if (_auth.currentUser == null) {
      return null;
    }

    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      return docSnapshot.data()?['userRole'] as String?;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Custom error messages for Firebase Auth exceptions
  // Modified _getFirebaseAuthErrorMessage method in auth_service.dart

  // Custom error messages for Firebase Auth exceptions
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email or try logging in.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'role-conflict':
        return 'This email address is used by a medical professional. Please choose another address.';
      case 'healthcare-role-conflict':
        return 'This email address is registered as a regular user. Please use a different email or login as a regular user.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}