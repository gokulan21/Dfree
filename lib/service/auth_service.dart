// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithCredentials(String username, String password, String role) async {
    try {
      // Create mock email for demo
      String email = '${username.toLowerCase()}@${role.toLowerCase()}.demo';
      
      try {
        // Try to sign in first
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // Update last login
        await _updateLastLogin(result.user!.uid);
        
        print('Sign in successful for: $email');
        return result;
        
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // User doesn't exist, create new account
          print('User not found, creating new account...');
          return await _createDemoUser(username, email, password, role);
        } else if (e.code == 'wrong-password') {
          throw Exception('Incorrect password. Please try again.');
        } else if (e.code == 'invalid-email') {
          throw Exception('Invalid email format.');
        } else if (e.code == 'user-disabled') {
          throw Exception('This account has been disabled.');
        } else {
          throw Exception('Authentication failed: ${e.message}');
        }
      }
    } catch (e) {
      print('Auth error: $e');
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  // Create demo user
  Future<UserCredential?> _createDemoUser(String username, String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(username);
        
        // Create user document
        await _createUserDocument(result.user!, username, role, email);
        
        print('Demo user created successfully: $email');
      }

      return result;
    } catch (e) {
      print('Create user error: $e');
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String username, String role, String email) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'username': username,
        'role': role,
        'fullName': username,
        'company': role == 'client' ? 'Demo Company Inc.' : 'Freelancer',
        'phone': '+1 (555) 123-4567',
        'profileImage': '',
        'bio': role == 'client' ? 'Looking for talented freelancers' : 'Experienced freelancer',
        'skills': role == 'freelancer' ? ['Flutter', 'Mobile Development', 'UI/UX'] : [],
        'hourlyRate': role == 'freelancer' ? 50.0 : 0.0,
        'rating': 0.0,
        'totalProjects': 0,
        'completedProjects': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
        'accountType': role,
        'platform': 'android',
        'isEmailVerified': false,
        'preferences': {
          'notifications': true,
          'darkMode': false,
          'language': 'en',
        },
      });
      
      print('User document created in Firestore');
    } catch (e) {
      print('Firestore error: $e');
      // Don't throw here as auth was successful
    }
  }

  // Update last login
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update last login error: $e');
      // Don't throw as this is not critical
    }
  }

  // Get user document
  Future<DocumentSnapshot?> getUserDocument(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print('Get user document error: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      print('User profile updated successfully');
    } catch (e) {
      print('Update user profile error: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
    } catch (e) {
      print('Reset password error: $e');
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete Firebase Auth account
        await user.delete();
        
        print('Account deleted successfully');
      }
    } catch (e) {
      print('Delete account error: $e');
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }
}
