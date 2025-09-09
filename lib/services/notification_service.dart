// Create: lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum NotificationType {
  projectCompleted,
  progressUpdated,
  projectAssigned,
  message,
}

class NotificationModel {
  final String id;
  final String recipientId;
  final String senderId;
  final String senderName;
  final String title;
  final String message;
  final NotificationType type;
  final String? projectId;
  final String? projectTitle;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.senderName,
    required this.title,
    required this.message,
    required this.type,
    this.projectId,
    this.projectTitle,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.message,
      ),
      projectId: data['projectId'],
      projectTitle: data['projectTitle'],
      data: data['data'] != null ? Map<String, dynamic>.from(data['data']) : null,
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName,
      'title': title,
      'message': message,
      'type': type.name,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send notification
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String message,
    required NotificationType type,
    String? projectId,
    String? projectTitle,
    Map<String, dynamic>? data,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      // Get sender name
      final senderDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final senderName = senderDoc.data()?['name'] ?? 'Unknown User';

      final notification = NotificationModel(
        id: '',
        recipientId: recipientId,
        senderId: currentUser.uid,
        senderName: senderName,
        title: title,
        message: message,
        type: type,
        projectId: projectId,
        projectTitle: projectTitle,
        data: data,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toFirestore());
    } catch (e) {
      throw Exception('Failed to send notification: ${e.toString()}');
    }
  }

  // Send project completion notification
  Future<void> sendProjectCompletionNotification({
    required String clientId,
    required String projectId,
    required String projectTitle,
    required String freelancerName,
  }) async {
    try {
      await sendNotification(
        recipientId: clientId,
        title: 'Project Completed! 🎉',
        message: '$freelancerName has completed the project "$projectTitle"',
        type: NotificationType.projectCompleted,
        projectId: projectId,
        projectTitle: projectTitle,
        data: {
          'completedAt': DateTime.now().toIso8601String(),
          'freelancerName': freelancerName,
        },
      );
    } catch (e) {
      throw Exception('Failed to send completion notification: ${e.toString()}');
    }
  }

  // Send progress update notification
  Future<void> sendProgressUpdateNotification({
    required String clientId,
    required String projectId,
    required String projectTitle,
    required String freelancerName,
    required int progress,
  }) async {
    try {
      await sendNotification(
        recipientId: clientId,
        title: 'Progress Update',
        message: '$freelancerName updated progress to $progress% for "$projectTitle"',
        type: NotificationType.progressUpdated,
        projectId: projectId,
        projectTitle: projectTitle,
        data: {
          'progress': progress,
          'updatedAt': DateTime.now().toIso8601String(),
          'freelancerName': freelancerName,
        },
      );
    } catch (e) {
      throw Exception('Failed to send progress notification: ${e.toString()}');
    }
  }

  // Get notifications for user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  // Mark all notifications as read for user
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      
      final notifications = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }
}
