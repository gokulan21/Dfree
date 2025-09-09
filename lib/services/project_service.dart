// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelance_hub/services/notification_service.dart';
import '../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create project
  Future<String> createProject(ProjectModel project) async {
    try {
      final docRef = await _firestore.collection('projects').add(project.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create project: ${e.toString()}');
    }
  }

  // Update project
  Future<void> updateProject(String projectId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('projects').doc(projectId).update(data);
    } catch (e) {
      throw Exception('Failed to update project: ${e.toString()}');
    }
  }

  // Delete project
  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete project: ${e.toString()}');
    }
  }

  // Get project by ID
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final doc = await _firestore.collection('projects').doc(projectId).get();
      if (doc.exists) {
        return ProjectModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get project: ${e.toString()}');
    }
  }

  // Get projects for client
  Stream<List<ProjectModel>> getClientProjects(String clientId) {
    return _firestore
        .collection('projects')
        .where('clientId', isEqualTo: clientId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  // Get projects for freelancer
  Stream<List<ProjectModel>> getFreelancerProjects(String freelancerId) {
    return _firestore
        .collection('projects')
        .where('freelancerId', isEqualTo: freelancerId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  // Get available projects (for freelancers to browse)
  Stream<List<ProjectModel>> getAvailableProjects() {
    return _firestore
        .collection('projects')
        .where('status', isEqualTo: ProjectStatus.pending.name)
        .where('freelancerId', isNull: true)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  // Apply for project (freelancer)
  Future<void> applyForProject(String projectId, String freelancerId, String message) async {
    try {
      await _firestore.collection('project_applications').add({
        'projectId': projectId,
        'freelancerId': freelancerId,
        'message': message,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to apply for project: ${e.toString()}');
    }
  }

  // Assign project to freelancer
  Future<void> assignProject(String projectId, String freelancerId, String freelancerName) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'freelancerId': freelancerId,
        'freelancerName': freelancerName,
        'status': ProjectStatus.inProgress.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to assign project: ${e.toString()}');
    }
  }

  // Update project progress
  Future<void> updateProjectProgress(String projectId, int progress) async {
    try {
      Map<String, dynamic> updateData = {
        'progress': progress,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // If progress is 100%, mark as completed
      if (progress >= 100) {
        updateData['status'] = ProjectStatus.completed.name;
        updateData['completedDate'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('projects').doc(projectId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update progress: ${e.toString()}');
    }
  }

  // Get project applications for a project
  Stream<List<Map<String, dynamic>>> getProjectApplications(String projectId) {
    return _firestore
        .collection('project_applications')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // Accept project application
  Future<void> acceptApplication(String applicationId, String projectId, String freelancerId, String freelancerName) async {
    try {
      final batch = _firestore.batch();

      // Update application status
      batch.update(
        _firestore.collection('project_applications').doc(applicationId),
        {'status': 'accepted', 'updatedAt': FieldValue.serverTimestamp()},
      );

      // Assign project
      batch.update(
        _firestore.collection('projects').doc(projectId),
        {
          'freelancerId': freelancerId,
          'freelancerName': freelancerName,
          'status': ProjectStatus.inProgress.name,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Reject other applications for this project
      final otherApplications = await _firestore
          .collection('project_applications')
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in otherApplications.docs) {
        if (doc.id != applicationId) {
          batch.update(doc.reference, {
            'status': 'rejected',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to accept application: ${e.toString()}');
    }
  }

  // Search projects
  Future<List<ProjectModel>> searchProjects(String query, {String? status}) async {
    try {
      Query projectsQuery = _firestore
          .collection('projects')
          .where('isActive', isEqualTo: true);

      if (status != null) {
        projectsQuery = projectsQuery.where('status', isEqualTo: status);
      }

      final results = await projectsQuery.get();

      return results.docs
          .map((doc) => ProjectModel.fromFirestore(doc))
          .where((project) =>
              project.title.toLowerCase().contains(query.toLowerCase()) ||
              project.description.toLowerCase().contains(query.toLowerCase()) ||
              project.skills.any((skill) => skill.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  // Get projects by status
  Stream<List<ProjectModel>> getProjectsByStatus(ProjectStatus status, {String? userId, String? userRole}) {
    Query query = _firestore
        .collection('projects')
        .where('status', isEqualTo: status.name)
        .where('isActive', isEqualTo: true);

    if (userId != null && userRole != null) {
      if (userRole == 'client') {
        query = query.where('clientId', isEqualTo: userId);
      } else if (userRole == 'freelancer') {
        query = query.where('freelancerId', isEqualTo: userId);
      }
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }
  // Add these methods to your existing ProjectService class

// Update project progress with notification
Future<void> updateProjectProgressWithNotification({
  required String projectId,
  required int progress,
  required String freelancerName,
}) async {
  try {
    // Get project details first
    final projectDoc = await _firestore.collection('projects').doc(projectId).get();
    if (!projectDoc.exists) throw Exception('Project not found');

    final project = ProjectModel.fromFirestore(projectDoc);
    
    Map<String, dynamic> updateData = {
      'progress': progress,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // If progress is 100%, mark as completed
    if (progress >= 100) {
      updateData['status'] = ProjectStatus.completed.name;
      updateData['completedDate'] = FieldValue.serverTimestamp();
    }

    // Update project in Firestore
    await _firestore.collection('projects').doc(projectId).update(updateData);

    // Send notifications
    final notificationService = NotificationService();
    
    if (progress >= 100) {
      // Send completion notification
      await notificationService.sendProjectCompletionNotification(
        clientId: project.clientId,
        projectId: projectId,
        projectTitle: project.title,
        freelancerName: freelancerName,
      );
      
      // Update freelancer's completed projects count
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'completedProjects': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } else {
      // Send progress update notification
      await notificationService.sendProgressUpdateNotification(
        clientId: project.clientId,
        projectId: projectId,
        projectTitle: project.title,
        freelancerName: freelancerName,
        progress: progress,
      );
    }
  } catch (e) {
    throw Exception('Failed to update progress: ${e.toString()}');
  }
}

}