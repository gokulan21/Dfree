// firestore_service.dart
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // **Freelancers Collection Methods**
  Future<void> addFreelancer(Freelancer freelancer) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('freelancers')
          .add({
        'name': freelancer.name,
        'role': freelancer.role,
        'rating': freelancer.rating,
        'skills': freelancer.skills,
        'workload': freelancer.workload,
        'email': freelancer.email,
        'phone': freelancer.phone,
        'bio': freelancer.bio,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'status': freelancer.workload > 80 ? 'busy' : 'available',
      });
    } catch (e) {
      print('Error adding freelancer: $e');
      rethrow;
    }
  }

  Stream<List<Freelancer>> getFreelancers() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('freelancers')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Freelancer(
          id: doc.id,
          name: data['name'] ?? '',
          role: data['role'] ?? '',
          rating: (data['rating'] ?? 0.0).toDouble(),
          skills: List<String>.from(data['skills'] ?? []),
          workload: data['workload'] ?? 0,
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          bio: data['bio'] ?? '',
        );
      }).toList();
    });
  }

  Future<void> updateFreelancer(String freelancerId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('freelancers')
          .doc(freelancerId)
          .update(data);
    } catch (e) {
      print('Error updating freelancer: $e');
      rethrow;
    }
  }

  Future<void> deleteFreelancer(String freelancerId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('freelancers')
          .doc(freelancerId)
          .update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting freelancer: $e');
      rethrow;
    }
  }

  // **Projects Collection Methods**
  Future<void> addProject(Project project) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('projects')
          .add({
        'name': project.name,
        'assignee': project.assignee,
        'dueDate': project.dueDate,
        'status': project.status.name,
        'progress': project.progress,
        'priority': project.priority.name,
        'description': project.description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'clientId': _userId,
      });
    } catch (e) {
      print('Error adding project: $e');
      rethrow;
    }
  }

  Stream<List<Project>> getProjects() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('projects')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Project(
          id: doc.id,
          name: data['name'] ?? '',
          assignee: data['assignee'] ?? '',
          dueDate: data['dueDate'] ?? '',
          status: _getProjectStatus(data['status']),
          progress: data['progress'] ?? 0,
          priority: _getPriority(data['priority']),
          description: data['description'] ?? '',
        );
      }).toList();
    });
  }

  ProjectStatus _getProjectStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'inprogress':
        return ProjectStatus.inProgress;
      case 'completed':
        return ProjectStatus.completed;
      case 'overdue':
        return ProjectStatus.overdue;
      case 'pending':
        return ProjectStatus.pending;
      default:
        return ProjectStatus.pending;
    }
  }

  Priority _getPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Priority.high;
      case 'medium':
        return Priority.medium;
      case 'low':
        return Priority.low;
      default:
        return Priority.medium;
    }
  }

  // **Chat Messages Methods**
  Future<void> sendMessage(String recipientName, String message) async {
    try {
      String chatId = _generateChatId(_userId, '${recipientName.toLowerCase()}_freelancer_id');
      
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': _userId,
        'recipientId': '${recipientName.toLowerCase()}_freelancer_id',
        'recipientName': recipientName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'messageType': 'text',
      });

      await _firestore.collection('chats').doc(chatId).set({
        'participants': [_userId, '${recipientName.toLowerCase()}_freelancer_id'],
        'participantNames': {
          _userId: 'Client',
          '${recipientName.toLowerCase()}_freelancer_id': recipientName,
        },
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Stream<List<ChatMessage>> getChatMessages(String recipientName) {
    String chatId = _generateChatId(_userId, '${recipientName.toLowerCase()}_freelancer_id');
    
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        Timestamp? timestamp = data['timestamp'];
        
        return ChatMessage(
          message: data['message'] ?? '',
          isReceived: data['senderId'] != _userId,
          time: timestamp != null 
              ? _formatTime(timestamp.toDate())
              : 'Now',
          timestamp: timestamp?.toDate(),
          senderId: data['senderId'],
        );
      }).toList();
    });
  }

  // **Analytics and Reports**
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      QuerySnapshot freelancersSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('freelancers')
          .where('isActive', isEqualTo: true)
          .get();

      QuerySnapshot projectsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('projects')
          .where('isActive', isEqualTo: true)
          .get();

      Map<String, int> projectsByStatus = {
        'inProgress': 0,
        'completed': 0,
        'overdue': 0,
        'pending': 0,
      };
      
      double totalRating = 0;
      int completedProjects = 0;
      int activeProjects = 0;

      for (var doc in projectsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'pending';
        
        projectsByStatus[status] = (projectsByStatus[status] ?? 0) + 1;
        
        if (status == 'completed') {
          completedProjects++;
        } else if (status == 'inProgress') {
          activeProjects++;
        }
      }

      for (var doc in freelancersSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] ?? 0.0).toDouble();
      }

      double averageRating = freelancersSnapshot.docs.isNotEmpty
          ? totalRating / freelancersSnapshot.docs.length
          : 0.0;

      return {
        'totalFreelancers': freelancersSnapshot.docs.length,
        'totalProjects': projectsSnapshot.docs.length,
        'activeProjects': activeProjects,
        'completedProjects': completedProjects,
        'averageRating': averageRating,
        'projectsByStatus': projectsByStatus,
        'completedThisMonth': completedProjects,
      };
    } catch (e) {
      print('Error getting dashboard metrics: $e');
      rethrow;
    }
  }

  // **Helper Methods**
  String _generateChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  Future getUserProfile() async {}

  Future<void> updateNotificationPreferences({required bool projectUpdates, required bool newMessages, required bool weeklyReports}) async {}

  Future<void> updateUserProfile(Map<String, String> updateData) async {}

  Future getAnalyticsData() async {}
}
