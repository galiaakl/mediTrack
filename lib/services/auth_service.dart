// File: lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  AuthService() {
    // Listen to authentication state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  bool isValidEmail(String email) {
    RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
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

      // Create user with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      // Generate a unique ID for healthcare professionals
      String? professionalId;
      if (userRole == 'healthcare') {
        professionalId = 'HC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      }

      // Store additional user data in Firestore (WITHOUT verification code)
      await _storeUserData(
        uid: userCredential.user!.uid,
        email: normalizedEmail,
        mobileNumber: mobileNumber,
        countryCode: countryCode,
        userRole: userRole,
        name: name,
        specialty: specialty,
        licenseNumber: licenseNumber,
        professionalId: professionalId,
      );

      // Send Firebase's built-in email verification
      await userCredential.user!.sendEmailVerification();

      if (kDebugMode) {
        print('✅ User created and verification email sent to: $normalizedEmail');
      }

      // Successfully created user
      return {
        'user': userCredential.user,
        'professionalId': professionalId,
      };
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getFirebaseAuthErrorMessage(e.code);
      if (kDebugMode) {
        print("Firebase Auth Exception: ${e.code} - ${_errorMessage}");
      }
      notifyListeners();
      return {'error': _errorMessage};
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      if (kDebugMode) {
        print("Error in createUserWithEmailAndPassword: $e");
      }
      notifyListeners();
      return {'error': _errorMessage};
    }
  }

  // Store user data in Firestore (SECURE VERSION)
  Future<void> _storeUserData({
    required String uid,
    required String email,
    required String mobileNumber,
    required String countryCode,
    required String userRole,
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
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false, // Will be updated when email is verified
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
        batch.set(_firestore.collection('healthcare_providers').doc(uid), userData);
      } else {
        batch.set(_firestore.collection('regular_users').doc(uid), userData);
      }

      await batch.commit();

      if (kDebugMode) {
        print("User data stored in Firestore for uid: $uid");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error storing user data in Firestore: $e");
      }
      throw e;
    }
  }

  // Check if email is verified using Firebase's built-in system
  Future<bool> isEmailVerified() async {
    if (_auth.currentUser == null) {
      return false;
    }

    try {
      // Reload the user to get the latest verification status
      await _auth.currentUser!.reload();

      // Check Firebase native verification status
      if (_auth.currentUser!.emailVerified) {
        // If Firebase shows verified, update our Firestore record
        await updateVerificationStatus();
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking verification status: $e');
      }
      return false;
    }
  }

  // Sign in existing user with email and password (SECURE VERSION)
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
      final normalizedEmail = email.trim().toLowerCase();

      if (kDebugMode) {
        print('📧 Attempting to send password reset to: $normalizedEmail');
      }

      await _auth.sendPasswordResetEmail(email: normalizedEmail);

      if (kDebugMode) {
        print('✅ Password reset email sent to: $normalizedEmail');
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseAuthErrorMessage(e.code);
      if (kDebugMode) {
        print('❌ Firebase Auth Exception: ${e.code} - ${_errorMessage}');
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ General Error: $e');
      }
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
          batch.update(_firestore.collection('healthcare_providers').doc(userId), {
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

  // Sign out (SECURE VERSION)
  Future<void> signOut() async {
    await _auth.signOut();
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
      if (kDebugMode) {
        print('Error getting user role: $e');
      }
      return null;
    }
  }

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