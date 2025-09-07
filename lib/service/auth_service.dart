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

  // Demo credentials - only username, role, and password
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

  // Sign in with credentials - improved to handle existing accounts
  Future<UserCredential?> signInWithCredentials(String username, String password, String role) async {
    try {
      print('🔄 Starting authentication process...');
      print('Username: $username, Role: $role');

      // Validate demo credentials first
      if (!_isValidDemoCredentials(username.trim().toLowerCase(), password, role)) {
        throw Exception('Invalid credentials. Please check your username and password.');
      }

      // Create dummy email for Firebase Auth
      String dummyEmail = '${username.toLowerCase().trim()}@${role.toLowerCase()}.demo';
      print('📧 Using email: $dummyEmail');

      try {
        // FIRST: Always try to sign in with existing account
        print('🔑 Attempting to sign in with existing account...');
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: dummyEmail,
          password: password,
        );
        
        print('✅ Sign in successful with existing account!');
        
        // Update user info in Firestore
        await _updateOrCreateUserDocument(result.user!, username, role);
        
        return result;
        
      } on FirebaseAuthException catch (e) {
        print('🔍 Firebase Auth Error: ${e.code} - ${e.message}');
        
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          // Account doesn't exist, create new one
          print('👤 Account not found, creating new account...');
          return await _createNewAccount(username, password, role, dummyEmail);
          
        } else if (e.code == 'wrong-password') {
          throw Exception('Incorrect password. Please check your password.');
          
        } else if (e.code == 'invalid-email') {
          throw Exception('Invalid email format.');
          
        } else if (e.code == 'user-disabled') {
          throw Exception('This account has been disabled.');
          
        } else if (e.code == 'too-many-requests') {
          throw Exception('Too many failed attempts. Please try again later.');
          
        } else if (e.code == 'network-request-failed') {
          throw Exception('Network error. Please check your internet connection.');
          
        } else {
          throw Exception('Login failed: ${e.message ?? "Unknown error"}');
        }
      }
      
    } catch (e) {
      print('❌ Authentication error: $e');
      rethrow;
    }
  }

  // Create new Firebase Auth account
  Future<UserCredential?> _createNewAccount(String username, String password, String role, String email) async {
    try {
      print('👤 Creating new Firebase Auth account...');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        print('✅ Firebase Auth account created successfully');
        
        // Update display name
        await result.user!.updateDisplayName(username);
        
        // Create/update user document in Firestore
        await _updateOrCreateUserDocument(result.user!, username, role);
      }

      return result;
      
    } on FirebaseAuthException catch (e) {
      print('❌ Error creating Firebase Auth account: ${e.code} - ${e.message}');
      
      if (e.code == 'email-already-in-use') {
        // Email exists, try to sign in instead
        print('📧 Email already exists, attempting to sign in...');
        try {
          UserCredential result = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('✅ Signed in with existing account');
          await _updateOrCreateUserDocument(result.user!, username, role);
          return result;
        } catch (signInError) {
          throw Exception('Account exists but password is incorrect. Please check your password.');
        }
      } else if (e.code == 'weak-password') {
        throw Exception('Password is too weak.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email format.');
      } else {
        throw Exception('Account creation failed: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      print('❌ General error creating account: $e');
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  // Update or create user document in Firestore
  Future<void> _updateOrCreateUserDocument(User user, String username, String role) async {
    try {
      print('📄 Updating/creating user document in Firestore...');
      
      // Check if document exists
      DocumentSnapshot existingDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (existingDoc.exists) {
        // Update existing document
        print('🔄 Updating existing user document...');
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
          'username': username,
          'role': role,
          'isActive': true,
          'metadata.loginCount': FieldValue.increment(1),
          'metadata.lastActiveDate': FieldValue.serverTimestamp(),
        });
        print('✅ User document updated successfully');
      } else {
        // Create new document
        print('📝 Creating new user document...');
        await _createUserDocument(user.uid, username, role);
      }
      
    } catch (e) {
      print('❌ Error updating/creating user document: $e');
      // Don't throw here, auth was successful
      print('⚠️ Auth successful but Firestore operation failed');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(String userId, String username, String role) async {
    try {
      Map<String, dynamic> userData = {
        'uid': userId,
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
        'preferences': {
          'notifications': true,
          'darkMode': true,
          'language': 'en',
        },
        'metadata': {
          'loginCount': 1,
          'deviceInfo': 'Android Demo',
          'lastActiveDate': FieldValue.serverTimestamp(),
        }
      };

      await _firestore.collection('users').doc(userId).set(userData);
      print('✅ User document created successfully in Firestore');
      
    } catch (e) {
      print('❌ Firestore error: $e');
      print('⚠️ Auth successful but user document creation failed');
    }
  }

  // Validate demo credentials
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
    
    // Check exact username match
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

  // Get user role from Firestore
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

  // Get current user info
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          return {
            'uid': user.uid,
            'username': data?['username'],
            'role': data?['role'],
            'displayName': user.displayName,
            'email': user.email, // This will be the dummy email
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user info: $e');
      return null;
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

  // Clean up demo accounts (for development)
  Future<void> cleanUpDemoAccounts() async {
    try {
      print('🧹 Cleaning up demo accounts...');
      
      // Sign out current user first
      await signOut();
      
      List<String> demoEmails = [
        'hdkdj@client.demo',
        'gokul@freelancer.demo',
        'client@client.demo',
        'freelancer@freelancer.demo',
      ];
      
      for (String email in demoEmails) {
        try {
          // Delete from Firestore
          QuerySnapshot users = await _firestore
              .collection('users')
              .where('username', isEqualTo: email.split('@')[0])
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
      print('❌ Error cleaning demo accounts: $e');
    }
  }
}