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

  // Demo credentials for testing
  final Map<String, String> _demoCredentials = {
    'client': 'client123',
    'freelancer': 'free123',
  };

  // Sign in with credentials - improved version
  Future<UserCredential?> signInWithCredentials(String username, String password, String role) async {
    try {
      print('🔄 Starting authentication process...');
      print('Username: $username, Role: $role');

      // Validate demo credentials first
      if (!_isValidDemoCredentials(username, password, role)) {
        throw Exception('Invalid demo credentials. Please check your username, password, and role.');
      }

      // Create demo email
      String email = '${username.toLowerCase().replaceAll(' ', '')}@${role.toLowerCase()}.demo';
      print('📧 Generated email: $email');

      try {
        // Try to sign in first
        print('🔑 Attempting to sign in...');
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        print('✅ Sign in successful!');
        await _updateLastLogin(result.user!.uid);
        return result;
        
      } on FirebaseAuthException catch (e) {
        print('🔍 Firebase Auth Error: ${e.code} - ${e.message}');
        
        if (e.code == 'user-not-found') {
          print('👤 User not found, creating new account...');
          return await _createDemoUser(username, email, password, role);
        } else if (e.code == 'wrong-password') {
          print('❌ Wrong password - attempting account recreation...');
          // For demo purposes, recreate the account if password is wrong
          return await _recreateDemoUser(username, email, password, role);
        } else if (e.code == 'invalid-email') {
          throw Exception('Invalid email format: $email');
        } else if (e.code == 'user-disabled') {
          throw Exception('This account has been disabled.');
        } else if (e.code == 'too-many-requests') {
          throw Exception('Too many failed attempts. Please try again later.');
        } else if (e.code == 'network-request-failed') {
          throw Exception('Network error. Please check your internet connection.');
        } else {
          print('🔄 Attempting to create new account due to error: ${e.code}');
          return await _createDemoUser(username, email, password, role);
        }
      }
    } catch (e) {
      print('❌ Authentication error: $e');
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  // Validate demo credentials
  bool _isValidDemoCredentials(String username, String password, String role) {
    if (username.trim().isEmpty) {
      print('❌ Username is empty');
      return false;
    }
    
    if (role.isEmpty || !_demoCredentials.containsKey(role)) {
      print('❌ Invalid role: $role');
      return false;
    }
    
    if (password != _demoCredentials[role]) {
      print('❌ Invalid password for role $role');
      print('Expected: ${_demoCredentials[role]}, Got: $password');
      return false;
    }
    
    print('✅ Demo credentials validated');
    return true;
  }

  // Recreate demo user (for demo purposes when wrong password)
  Future<UserCredential?> _recreateDemoUser(String username, String email, String password, String role) async {
    try {
      print('🔄 Recreating demo user...');
      
      // For demo, we'll try to delete the existing user if possible
      try {
        // First try to sign in with any password to get the user
        UserCredential tempResult = await _auth.signInWithEmailAndPassword(
          email: email, 
          password: 'temppassword123' // This will likely fail
        );
        await tempResult.user?.delete();
        print('🗑️ Deleted existing user');
      } catch (e) {
        print('ℹ️ Could not delete existing user (expected): $e');
      }

      // Wait a bit before creating new account
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Create new account
      return await _createDemoUser(username, email, password, role);
      
    } catch (e) {
      print('❌ Error recreating user: $e');
      throw Exception('Could not recreate demo account: ${e.toString()}');
    }
  }

  // Create demo user with better error handling
  Future<UserCredential?> _createDemoUser(String username, String email, String password, String role) async {
    try {
      print('👤 Creating new demo user...');
      print('Email: $email');

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        print('✅ User created successfully');
        
        // Update display name
        await result.user!.updateDisplayName(username);
        print('✅ Display name updated');
        
        // Create user document
        await _createUserDocument(result.user!, username, role, email);
        print('✅ User document created');
      }

      return result;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error during creation: ${e.code} - ${e.message}');
      
      if (e.code == 'email-already-in-use') {
        // Email exists, try to sign in instead
        print('🔄 Email already in use, attempting sign in...');
        try {
          return await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (signInError) {
          throw Exception('Account exists but password is incorrect. Demo account may be corrupted.');
        }
      } else if (e.code == 'weak-password') {
        throw Exception('Password is too weak. Please use a stronger password.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email format: $email');
      } else if (e.code == 'network-request-failed') {
        throw Exception('Network error. Please check your internet connection.');
      } else {
        throw Exception('Account creation failed: ${e.message}');
      }
    } catch (e) {
      print('❌ General error during user creation: $e');
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  // Create user document in Firestore with better error handling
  Future<void> _createUserDocument(User user, String username, String role, String email) async {
    try {
      print('📄 Creating user document in Firestore...');
      
      Map<String, dynamic> userData = {
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
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
      print('✅ User document created successfully');
      
    } catch (e) {
      print('❌ Firestore error: $e');
      // Don't throw here as auth was successful
      print('⚠️ Auth successful but Firestore document creation failed');
    }
  }

  // Update last login with error handling
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      print('✅ Last login updated');
    } catch (e) {
      print('⚠️ Could not update last login: $e');
      // Don't throw as this is not critical
    }
  }

  // Get user document
  Future<DocumentSnapshot?> getUserDocument(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      print('📄 User document retrieved');
      return doc;
    } catch (e) {
      print('❌ Error getting user document: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
      print('✅ User profile updated');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password for demo accounts
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent');
    } catch (e) {
      print('❌ Reset password error: $e');
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
        
        print('✅ Account deleted successfully');
      }
    } catch (e) {
      print('❌ Delete account error: $e');
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Clear demo accounts (for development/testing)
  Future<void> clearDemoAccounts() async {
    try {
      // This is a demo method - in production you wouldn't have this
      print('🧹 Clearing demo accounts...');
      
      List<String> demoEmails = [
        'client@client.demo',
        'freelancer@freelancer.demo',
        'hdkdj@client.demo', // Based on your screenshot
      ];
      
      for (String email in demoEmails) {
        try {
          // Try to delete user documents from Firestore
          QuerySnapshot users = await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .get();
              
          for (DocumentSnapshot doc in users.docs) {
            await doc.reference.delete();
            print('🗑️ Deleted Firestore document for $email');
          }
        } catch (e) {
          print('⚠️ Could not delete Firestore document for $email: $e');
        }
      }
      
      print('✅ Demo account cleanup completed');
    } catch (e) {
      print('❌ Error clearing demo accounts: $e');
    }
  }
}