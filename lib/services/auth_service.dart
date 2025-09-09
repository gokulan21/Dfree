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

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Get current user role
  Future<String?> getCurrentUserRole() async {
    try {
      final userData = await getCurrentUserData();
      return userData?.role;
    } catch (e) {
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
        email: email,
        password: password,
      );

      // If expectedRole is provided, validate user's role
      if (expectedRole != null && result.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Sign out the user since profile doesn't exist
          await _auth.signOut();
          throw Exception('User profile not found. Please contact support.');
        }

        final userData = userDoc.data();
        final userRole = userData?['role'] as String?;

        if (userRole == null) {
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
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
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
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user document
        final userModel = UserModel(
          id: result.user!.uid,
          email: email,
          name: name,
          role: role,
          phone: phone,
          company: company,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userModel.toFirestore());

        // Update display name
        await result.user!.updateDisplayName(name);
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

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(user.uid).update(data);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
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

      // Delete user document
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete auth account
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Handle auth exceptions
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
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }

  // Demo sign in method (for testing) with role validation
  Future<UserCredential> signInDemo(String username, String expectedRole) async {
    try {
      String email = '${username.toLowerCase()}@${expectedRole.toLowerCase()}.demo';
      String password = 'demo123';

      try {
        return await signInWithEmailAndPassword(
          email, 
          password, 
          expectedRole: expectedRole,
        );
      } on Exception catch (e) {
        if (e.toString().contains('No account found') || 
            e.toString().contains('user-not-found')) {
          // Create demo account with proper role name formatting
          String displayName = expectedRole == 'client' ? 'Client Demo User' : 'Freelancer Demo User';
          
          return await createUserWithEmailAndPassword(
            email: email,
            password: password,
            name: displayName,
            role: expectedRole,
            company: expectedRole == 'client' ? 'Demo Company' : null,
          );
        }
        rethrow;
      }
    } catch (e) {
      throw Exception('Demo sign in failed: ${e.toString()}');
    }
  }
}