// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Get all freelancers
  Future<List<UserModel>> getFreelancers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'freelancer')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.id != _currentUserId) // Exclude current user
          .toList();
    } catch (e) {
      print('Error getting freelancers: $e');
      throw Exception('Failed to get freelancers: ${e.toString()}');
    }
  }

  // Get all clients (for freelancers to see)
  Future<List<UserModel>> getClients() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'client')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.id != _currentUserId) // Exclude current user
          .toList();
    } catch (e) {
      print('Error getting clients: $e');
      throw Exception('Failed to get clients: ${e.toString()}');
    }
  }

  // Search users by role and query
  Future<List<UserModel>> searchUsers({
    required String role,
    required String searchQuery,
  }) async {
    try {
      if (searchQuery.isEmpty) {
        return role == 'freelancer' ? await getFreelancers() : await getClients();
      }

      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.id != _currentUserId)
          .toList();

      // Filter by search query using basic UserModel fields
      return users.where((user) =>
          user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (user.company != null && user.company!.toLowerCase().contains(searchQuery.toLowerCase()))
      ).toList();
    } catch (e) {
      print('Error searching users: $e');
      throw Exception('Failed to search users: ${e.toString()}');
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // Get multiple users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      // Firestore 'in' query has a limit of 10 items
      final chunks = <List<String>>[];
      for (int i = 0; i < userIds.length; i += 10) {
        chunks.add(userIds.skip(i).take(10).toList());
      }

      final List<UserModel> users = [];
      for (final chunk in chunks) {
        final querySnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        users.addAll(
          querySnapshot.docs.map((doc) => UserModel.fromFirestore(doc))
        );
      }

      return users;
    } catch (e) {
      print('Error getting users by IDs: $e');
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }

  // Get online users (based on last activity) - simplified version
  Future<List<UserModel>> getOnlineUsers(String role) async {
    try {
      final thirtyMinutesAgo = DateTime.now().subtract(const Duration(minutes: 30));
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .where('lastLogin', isGreaterThan: Timestamp.fromDate(thirtyMinutesAgo))
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.id != _currentUserId)
          .toList();
    } catch (e) {
      print('Error getting online users: $e');
      // Return all users if online check fails
      return role == 'freelancer' ? await getFreelancers() : await getClients();
    }
  }

  // Update user's last seen timestamp - simplified version
  Future<void> updateLastSeen() async {
    try {
      if (_currentUserId.isEmpty) return;

      await _firestore.collection('users').doc(_currentUserId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last seen: $e');
      // Don't throw error for this non-critical operation
    }
  }

  // Get user statistics - simplified version
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return {};

      // Get chat rooms count
      final chatRoomsSnapshot = await _firestore
          .collection('chats')
          .where('participantIds', arrayContains: userId)
          .get();

      return {
        'totalChats': chatRoomsSnapshot.docs.length,
        'memberSince': user.createdAt,
        'lastLogin': user.lastLogin,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  // Stream of users (real-time updates)
  Stream<List<UserModel>> streamFreelancers() {
    try {
      return _firestore
          .collection('users')
          .where('role', isEqualTo: 'freelancer')
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .where((user) => user.id != _currentUserId)
                .toList();
          });
    } catch (e) {
      print('Error streaming freelancers: $e');
      return Stream.value(<UserModel>[]);
    }
  }

  Stream<List<UserModel>> streamClients() {
    try {
      return _firestore
          .collection('users')
          .where('role', isEqualTo: 'client')
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .where((user) => user.id != _currentUserId)
                .toList();
          });
    } catch (e) {
      print('Error streaming clients: $e');
      return Stream.value(<UserModel>[]);
    }
  }
}