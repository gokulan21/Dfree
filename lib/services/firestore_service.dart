import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // User operations
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  // Get freelancers
  Stream<List<UserModel>> getFreelancers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'freelancer')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Get clients
  Stream<List<UserModel>> getClients() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'client')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Search users by skills or name
  Future<List<UserModel>> searchFreelancers(String query) async {
    try {
      final results = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'freelancer')
          .where('isActive', isEqualTo: true)
          .get();

      return results.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.skills.any((skill) => skill.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  // Get dashboard metrics for client
  Future<Map<String, dynamic>> getClientDashboardMetrics(String clientId) async {
    try {
      final projectsSnapshot = await _firestore
          .collection('projects')
          .where('clientId', isEqualTo: clientId)
          .where('isActive', isEqualTo: true)
          .get();

      int totalProjects = projectsSnapshot.docs.length;
      int activeProjects = 0;
      int completedProjects = 0;
      int pendingProjects = 0;
      double totalBudget = 0;
      double totalPaid = 0;

      for (var doc in projectsSnapshot.docs) {
        final project = ProjectModel.fromFirestore(doc);
        totalBudget += project.budget;
        totalPaid += project.paidAmount ?? 0;

        switch (project.status) {
          case ProjectStatus.inProgress:
            activeProjects++;
            break;
          case ProjectStatus.completed:
            completedProjects++;
            break;
          case ProjectStatus.pending:
            pendingProjects++;
            break;
          default:
            break;
        }
      }

      return {
        'totalProjects': totalProjects,
        'activeProjects': activeProjects,
        'completedProjects': completedProjects,
        'pendingProjects': pendingProjects,
        'totalBudget': totalBudget,
        'totalPaid': totalPaid,
        'averageRating': 4.8, // Calculate from actual ratings
      };
    } catch (e) {
      throw Exception('Failed to get metrics: ${e.toString()}');
    }
  }

  // Get dashboard metrics for freelancer
  Future<Map<String, dynamic>> getFreelancerDashboardMetrics(String freelancerId) async {
    try {
      final projectsSnapshot = await _firestore
          .collection('projects')
          .where('freelancerId', isEqualTo: freelancerId)
          .where('isActive', isEqualTo: true)
          .get();

      int totalProjects = projectsSnapshot.docs.length;
      int activeProjects = 0;
      int completedProjects = 0;
      double totalEarnings = 0;

      for (var doc in projectsSnapshot.docs) {
        final project = ProjectModel.fromFirestore(doc);
        
        if (project.status == ProjectStatus.completed) {
          completedProjects++;
          totalEarnings += project.paidAmount ?? 0;
        } else if (project.status == ProjectStatus.inProgress) {
          activeProjects++;
        }
      }

      return {
        'totalProjects': totalProjects,
        'activeProjects': activeProjects,
        'completedProjects': completedProjects,
        'totalEarnings': totalEarnings,
        'averageRating': 4.8, // Calculate from actual ratings
      };
    } catch (e) {
      throw Exception('Failed to get metrics: ${e.toString()}');
    }
  }

  // Batch operations
  Future<void> batchUpdate(List<Map<String, dynamic>> updates) async {
    try {
      final batch = _firestore.batch();
      
      for (var update in updates) {
        final docRef = _firestore.collection(update['collection']).doc(update['id']);
        batch.update(docRef, update['data']);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Batch update failed: ${e.toString()}');
    }
  }
}
