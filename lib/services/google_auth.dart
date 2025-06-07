// File: lib/services/google_auth.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard, // This ensures account selection dialog shows
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle(BuildContext context, {required String userRole}) async {
    try {
      // Always clear any existing sign-in to force account picker
      await _googleSignIn.signOut();

      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User canceled the sign-in flow
      if (googleUser == null) {
        return null;
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // New user - check if email exists in the other role collection
        final email = userCredential.user!.email!;
        final oppositeRole = userRole == 'healthcare' ? 'regular' : 'healthcare';

        final existingUsers = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .where('userRole', isEqualTo: oppositeRole)
            .get();

        if (existingUsers.docs.isNotEmpty) {
          // Role conflict - sign out and show error
          await _auth.signOut();

          if (existingUsers.docs.isNotEmpty) {
            // Role conflict - sign out and show error
            await _auth.signOut();

            String errorMessage = userRole == 'healthcare'
                ? 'This email address is registered as a regular user. Please use a different email or login as a regular user.'
                : 'This email address is used by a medical professional. Please choose another address.';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );

            return null;
          }

          return null;
        }

        // Store with the provided role
        await _storeUserData(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName ?? '',
          photoURL: userCredential.user!.photoURL,
          userRole: userRole,
        );

        // Save auto-login preference
        await _saveAutoLoginPreference(true);
      } else {
        // Existing user - check if role matches
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final existingRole = userData['userRole'] as String?;

          if (existingRole != null && existingRole != userRole) {
            // Role mismatch - sign out and show error
            await _auth.signOut();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    existingRole == 'healthcare'
                        ? 'This account is registered as a healthcare provider. Please use the healthcare login.'
                        : 'This account is registered as a regular user. Please use the regular user login.'
                ),
                backgroundColor: Colors.red,
              ),
            );

            return null;
          } else {
            // Role matches, save auto-login preference
            await _saveAutoLoginPreference(true);
          }
        } else {
          // User exists in Auth but not in Firestore - create the record
          await _storeUserData(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email!,
            displayName: userCredential.user!.displayName ?? '',
            photoURL: userCredential.user!.photoURL,
            userRole: userRole,
          );

          // Save auto-login preference
          await _saveAutoLoginPreference(true);
        }
      }

      return userCredential;
    } catch (e) {
      // Handle errors
      print('Error signing in with Google: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing in with Google: $e'),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }
  }

  // Store user data for Google Sign-In
  Future<void> _storeUserData({
    required String uid,
    required String email,
    required String displayName,
    String? photoURL,
    required String userRole,
  }) async {
    try {
      final batch = _firestore.batch();

      final Map<String, dynamic> userData = {
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'userRole': userRole,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': true, // Google accounts are pre-verified
        'signInMethod': 'google',
      };

      // Add to main users collection
      batch.set(_firestore.collection('users').doc(uid), userData);

      // Add to role-specific collection
      if (userRole == 'healthcare') {
        userData['isApproved'] = false; // Healthcare providers need approval
        batch.set(_firestore.collection('healthcare_providers').doc(uid), userData);
      } else {
        batch.set(_firestore.collection('regular_users').doc(uid), userData);
      }

      await batch.commit();
    } catch (e) {
      print('Error storing user data: $e');
      throw e;
    }
  }

  // Save auto-login preference
  Future<void> _saveAutoLoginPreference(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoLogin', enabled);
    } catch (e) {
      print('Error saving auto-login preference: $e');
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

  // Auto-login with Google
  Future<User?> autoLoginWithGoogle() async {
    try {
      if (await isAutoLoginEnabled()) {
        // Get currently signed-in user if any
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          return currentUser;
        }

        // Try silent sign-in (may not work if user has signed out from Google)
        final googleUser = await _googleSignIn.signInSilently();
        if (googleUser != null) {
          final googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final userCredential = await _auth.signInWithCredential(credential);
          return userCredential.user;
        }
      }
      return null;
    } catch (e) {
      print('Auto-login with Google failed: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Clear auto-login preference
      await _saveAutoLoginPreference(false);
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }
}

// Widget for Google Sign-In Button
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: isLoading
          ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
            height: 20,
            width: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            'Sign in with Google',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}