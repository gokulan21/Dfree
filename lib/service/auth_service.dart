// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

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
  final Map<String, Map<String, String>> _demoCredentials = {
    'client': {
      'hdkdj': 'client123',
      'client': 'client123',
      'demo': 'client123',
    },
    'freelancer': {
      'gokul': 'free123',
      'freelancer': 'free123',
      'demo': 'free123',
    },
  };

  // Sign in with credentials - simplified and fixed version
  Future<UserCredential?> signInWithCredentials(String username, String password, String role) async {
    try {
      print('🔄 Starting authentication process...');
      print('Username: $username, Role: $role, Password: $password');

      // Validate demo credentials first
      if (!_isValidDemoCredentials(username.trim().toLowerCase(), password, role)) {
        throw Exception('Invalid credentials. Please check your username and password.');
      }

      // Create consistent demo email based on username and role
      String cleanUsername = username.trim().toLowerCase().replaceAll(' ', '');
      String email = '${cleanUsername}@${role.toLowerCase()}.demo';
      
      print('📧 Generated email: $email');

      try {
        // Try to sign in first
        print('🔑 Attempting to sign in with existing account...');
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        print('✅ Sign in successful with existing account!');
        await _updateUserDocument(result.user!, username, role);
        return result;
        
      } on FirebaseAuthException catch (e) {
        print('🔍 Firebase Auth Error: ${e.code} - ${e.message}');
        
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          print('👤 User not found, creating new demo account...');
          return await _createDemoUser(username, email, password, role);
        } else if (e.code == 'wrong-password') {
          throw Exception('Incorrect password for this account.');
        } else if (e.code == 'invalid-email') {
          throw Exception('Invalid email format.');
        } else if (e.code == 'user-disabled') {
          throw Exception('This account has been disabled.');
        } else if (e.code == 'too-many-requests') {
          throw Exception('Too many failed login attempts. Please try again later.');
        } else if (e.code == 'network-request-failed') {
          throw Exception('Network error. Please check your internet connection.');
        } else {
          // For any other error, try creating a new account
          print('🔄 Attempting to create new account for: ${e.code}');
          return await _createDemoUser(username, email, password, role);
        }
      }
    } catch (e) {
      print('❌ Authentication error: $e');
      rethrow;
    }
  }

  // Validate demo credentials with improved logic
  bool _isValidDemoCredentials(String username, String password, String role) {
    if (username.isEmpty) {
      print('❌ Username is empty');
      return false;
    }
    
    if (role.isEmpty || !_demoCredentials.containsKey(role)) {
      print('❌ Invalid role: $role');
      return false;
    }
    
    // Check if username exists for this role and password matches
    Map<String, String> roleCredentials = _demoCredentials[role]!;
    
    // Check exact username match or use default password for any username
    if (roleCredentials.containsKey(username)) {
      bool isValid = password == roleCredentials[username];
      print(isValid ? '✅ Demo credentials validated for specific user' : '❌ Invalid password for user $username');
      return isValid;
    } else {
      // Allow any username with the default role password
      String defaultPassword = role == 'client' ? 'client123' : 'free123';
      bool isValid = password == defaultPassword;
      print(isValid ? '✅ Demo credentials validated with default password' : '❌ Invalid password for role $role');
      return isValid;
    }
  }

  // Create demo user with better error handling
  Future<UserCredential?> _createDemoUser(String username, String email, String password, String role) async {
    try {
      print('👤 Creating new demo user...');
      print('Email: $email, Username: $username, Role: $role');

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        print('✅ Firebase Auth user created successfully');
        
        // Update display name
        await result.user!.updateDisplayName(username);
        print('✅ Display name updated to: $username');
        
        // Create user document in Firestore
        await _createUserDocument(result.user!, username, role, email);
        print('✅ User document created in Firestore');
      }

      return result;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error during creation: ${e.code} - ${e.message}');
      
      if (e.code == 'email-already-in-use') {
        print('📧 Email already exists, attempting to sign in...');
        try {
          // Email exists, try to sign in instead
          UserCredential result = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('✅ Signed in with existing account');
          await _updateUserDocument(result.user!, username, role);
          return result;
        } catch (signInError) {
          throw Exception('Account exists but credentials don\'t match. Please try a different username.');
        }
      } else if (e.code == 'weak-password') {
        throw Exception('Password is too weak.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email format.');
      } else if (e.code == 'network-request-failed') {
        throw Exception('Network error. Please check your internet connection.');
      } else {
        throw Exception('Account creation failed: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ General error during user creation: $e');
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String username, String role, String email) async {
    try {
      print('📄 Creating user document in Firestore...');
      
      Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': email,
        'username': username,
        'role': role,
        'fullName': username,
        'company': role == 'client' ? 'Demo Company Inc.' : null,
        'phone': '+1 (555) 123-4567',
        'profileImage': null,
        'bio': role == 'client' ? 'Demo client account' : 'Demo freelancer account',
        'skills': role == 'freelancer' ? ['Flutter', 'Mobile Development'] : [],
        'hourlyRate': role == 'freelancer' ? 50.0 : null,
        'rating': role == 'freelancer' ? 4.5 : null,
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
          'darkMode': true,
          'language': 'en',
        },
        'metadata': {
          'loginCount': 1,
          'lastActiveDate': FieldValue.serverTimestamp(),
          'deviceInfo': 'Android Demo',
        }
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
      print('✅ User document created successfully in Firestore');
      
    } catch (e) {
      print('❌ Firestore error: $e');
      // Don't throw here as auth was successful, just log the error
      print('⚠️ Auth successful but user document creation failed - this is not critical');
    }
  }

  // Update existing user document
  Future<void> _updateUserDocument(User user, String username, String role) async {
    try {
      print('🔄 Updating existing user document...');
      
      Map<String, dynamic> updateData = {
        'lastLogin': FieldValue.serverTimestamp(),
        'username': username, // Update username in case it changed
        'role': role, // Update role in case it changed
        'isActive': true,
        'metadata.loginCount': FieldValue.increment(1),
        'metadata.lastActiveDate': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).update(updateData);
      print('✅ User document updated successfully');
      
    } catch (e) {
      print('⚠️ Could not update user document: $e');
      // Try to create the document if it doesn't exist
      try {
        await _createUserDocument(user, username, role, user.email ?? '');
      } catch (createError) {
        print('⚠️ Could not create user document either: $createError');
      }
    }
  }

  // Get user document
  Future<DocumentSnapshot?> getUserDocument(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      print('📄 User document retrieved successfully');
      return doc;
    } catch (e) {
      print('❌ Error getting user document: $e');
      return null;
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

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to: $email');
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
        // Delete user document from Firestore first
        await _firestore.collection('users').doc(user.uid).delete();
        print('✅ User document deleted from Firestore');
        
        // Delete Firebase Auth account
        await user.delete();
        print('✅ Firebase Auth account deleted');
      }
    } catch (e) {
      print('❌ Delete account error: $e');
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          return data?['role'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting user role: $e');
      return null;
    }
  }

  // Check if user is authenticated and get role
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          return {
            'uid': user.uid,
            'email': user.email,
            'username': data?['username'],
            'role': data?['role'],
            'displayName': user.displayName,
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user info: $e');
      return null;
    }
  }
}