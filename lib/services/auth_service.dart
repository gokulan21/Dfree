// ignore_for_file: unused_local_variable, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user data with better error handling
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) {
        print('No current user found');
        return null;
      }

      print('Fetching user data for UID: ${user.uid}');
      
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        print('User document found');
        return UserModel.fromFirestore(doc);
      } else {
        print('User document does not exist or is empty');
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Get current user role
  Future<String?> getCurrentUserRole() async {
    try {
      final userData = await getCurrentUserData();
      return userData?.role;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Sign in with email and password with role validation
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password, {
    String? expectedRole,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // If expectedRole is provided, validate user's role
      if (expectedRole != null && result.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();

        if (!userDoc.exists || userDoc.data() == null) {
          // Sign out the user since profile doesn't exist
          await _auth.signOut();
          throw Exception('User profile not found. Please contact support.');
        }

        final userData = userDoc.data()!;
        final userRole = userData['role'] as String?;

        if (userRole == null || userRole.isEmpty) {
          await _auth.signOut();
          throw Exception('User role not found. Please contact support.');
        }

        if (userRole != expectedRole) {
          // Sign out the user since role doesn't match
          await _auth.signOut();
          throw Exception(
            'No ${expectedRole.toLowerCase()} account found with this email. '
            'This email is registered as a ${userRole.toLowerCase()}.'
          );
        }

        // Update last login if role matches
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else if (result.user != null) {
        // Update last login for normal sign in without role validation
        try {
          await _firestore.collection('users').doc(result.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Warning: Could not update last login: $e');
          // Don't fail the entire sign in for this
        }
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Re-throw custom exceptions (like role validation errors)
      if (e.toString().contains('account found') || 
          e.toString().contains('profile not found') ||
          e.toString().contains('role not found')) {
        rethrow;
      }
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  // Create account with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? company,
  }) async {
    try {
      if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty || role.trim().isEmpty) {
        throw Exception('All required fields must be filled');
      }

      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Create user document
        final userModel = UserModel(
          id: result.user!.uid,
          email: email.trim().toLowerCase(),
          name: name.trim(),
          role: role.toLowerCase(),
          phone: phone?.trim(),
          company: company?.trim(),
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userModel.toFirestore());

        // Update display name
        try {
          await result.user!.updateDisplayName(name.trim());
        } catch (e) {
          print('Warning: Could not update display name: $e');
          // Don't fail the entire registration for this
        }
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Update user profile - IMPROVED VERSION with better validation
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Validate and clean data
      final cleanData = <String, dynamic>{};
      data.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          if (key == 'email') {
            cleanData[key] = value.toString().trim().toLowerCase();
          } else if (key == 'name' || key == 'company' || key == 'phone') {
            cleanData[key] = value.toString().trim();
          } else {
            cleanData[key] = value;
          }
        }
      });

      print('Updating profile for user: ${user.uid}');
      print('Update data: $cleanData');

      // Check if user document exists first
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('User document not found. Please contact support.');
      }

      // Add timestamp
      cleanData['updatedAt'] = FieldValue.serverTimestamp();

      // Perform the update
      await docRef.update(cleanData);
      
      print('Profile update completed successfully');

      // Update display name if name was changed
      if (cleanData.containsKey('name')) {
        try {
          await user.updateDisplayName(cleanData['name']);
          print('Display name updated successfully');
        } catch (e) {
          print('Warning: Could not update display name: $e');
          // Don't throw error for display name update failure
        }
      }

    } on FirebaseException catch (e) {
      print('Firestore error: ${e.code} - ${e.message}');
      throw Exception('Database error: ${e.message ?? 'Unknown database error'}');
    } catch (e) {
      print('Generic error updating profile: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw Exception('Email address is required');
      }
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Delete user document first
      try {
        await _firestore.collection('users').doc(user.uid).delete();
      } catch (e) {
        print('Warning: Could not delete user document: $e');
      }

      // Delete auth account
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Handle auth exceptions with better error messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email address.');
      case 'weak-password':
        return Exception('Password is too weak. Please choose a stronger password.');
      case 'invalid-email':
        return Exception('Invalid email address format.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later.');
      case 'invalid-credential':
        return Exception('Invalid email or password. Please check your credentials.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection and try again.');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed. Please contact support.');
      default:
        return Exception('Authentication error: ${e.message ?? 'Unknown error'}');
    }
  }

  // Demo sign in method (for testing) with role validation
  Future<UserCredential> signInDemo(String username, String expectedRole) async {
    try {
      if (username.trim().isEmpty || expectedRole.trim().isEmpty) {
        throw Exception('Username and role are required');
      }

      String email = '${username.toLowerCase().trim()}@${expectedRole.toLowerCase()}.demo';
      String password = 'demo123';

      try {
        return await signInWithEmailAndPassword(
          email, 
          password, 
          expectedRole: expectedRole.toLowerCase(),
        );
      } on Exception catch (e) {
        if (e.toString().contains('No account found') || 
            e.toString().contains('user-not-found')) {
          // Create demo account with proper role name formatting
          String displayName = expectedRole.toLowerCase() == 'client' 
              ? 'Client Demo User' 
              : 'Freelancer Demo User';
          
          return await createUserWithEmailAndPassword(
            email: email,
            password: password,
            name: displayName,
            role: expectedRole.toLowerCase(),
            company: expectedRole.toLowerCase() == 'client' ? 'Demo Company' : null,
          );
        }
        rethrow;
      }
    } catch (e) {
      throw Exception('Demo sign in failed: ${e.toString()}');
    }
  }

  // Test connectivity method
  Future<bool> testFirestoreConnection() async {
    try {
      final user = currentUser;
      if (user == null) return false;
      
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));
      
      print('Firestore connection test successful');
      return true;
    } catch (e) {
      print('Firestore connection test failed: $e');
      return false;
    }
  }

  // Validate user session
  Future<bool> validateUserSession() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      // Reload user to get fresh data
      await user.reload();
      
      // Check if user document still exists
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists && doc.data() != null;
    } catch (e) {
      print('Session validation failed: $e');
      return false;
    }
  }
}