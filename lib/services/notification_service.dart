import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum NotificationType { 
  projectAssigned, 
  projectCompleted, 
  messageReceived, 
  paymentReceived,
  taskAssigned,
  taskCompleted,
  general 
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.data = const {},
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.general,
      ),
      isRead: data['isRead'] ?? false,
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic> data = const {},
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        message: message,
        type: type,
        data: data,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toFirestore());
    } catch (e) {
      debugPrint('Failed to create notification: $e');
    }
  }

  // Get user notifications
  Stream<List<NotificationModel>> getUserNotifications() {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: _currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: _currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      return unreadNotifications.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      debugPrint('Failed to delete notification: $e');
    }
  }

  // Notification helpers for specific events
  Future<void> notifyProjectAssigned(String freelancerId, String projectTitle) async {
    await createNotification(
      userId: freelancerId,
      title: 'New Project Assigned',
      message: 'You have been assigned to project: $projectTitle',
      type: NotificationType.projectAssigned,
    );
  }

  Future<void> notifyProjectCompleted(String clientId, String projectTitle) async {
    await createNotification(
      userId: clientId,
      title: 'Project Completed',
      message: 'Project "$projectTitle" has been completed',
      type: NotificationType.projectCompleted,
    );
  }

  Future<void> notifyNewMessage(String recipientId, String senderName) async {
    await createNotification(
      userId: recipientId,
      title: 'New Message',
      message: 'You have received a new message from $senderName',
      type: NotificationType.messageReceived,
    );
  }

  Future<void> notifyPaymentReceived(String freelancerId, double amount) async {
    await createNotification(
      userId: freelancerId,
      title: 'Payment Received',
      message: 'You have received a payment of \$${amount.toStringAsFixed(2)}',
      type: NotificationType.paymentReceived,
    );
  }
}
