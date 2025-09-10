import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file, system }

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final MessageType type;
  final String? fileUrl;
  final String? fileName;
  final DateTime timestamp;
  final bool isRead;
  final String? replyToId;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.type = MessageType.text,
    this.fileUrl,
    this.fileName,
    required this.timestamp,
    this.isRead = false,
    this.replyToId,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return ChatMessage(
        id: doc.id,
        chatId: data['chatId'] ?? '',
        senderId: data['senderId'] ?? '',
        senderName: data['senderName'] ?? '',
        message: data['message'] ?? '',
        type: MessageType.values.firstWhere(
          (e) => e.name == data['type'],
          orElse: () => MessageType.text,
        ),
        fileUrl: data['fileUrl'],
        fileName: data['fileName'],
        timestamp: data['timestamp'] != null 
            ? (data['timestamp'] as Timestamp).toDate()
            : DateTime.now(),
        isRead: data['isRead'] ?? false,
        replyToId: data['replyToId'],
      );
    } catch (e) {
      // Return a fallback message if parsing fails
      return ChatMessage(
        id: doc.id,
        chatId: '',
        senderId: '',
        senderName: 'Unknown',
        message: 'Message could not be loaded',
        timestamp: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'type': type.name,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'replyToId': replyToId,
    };
  }
}

class ChatRoom {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? projectId;

  ChatRoom({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCount = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.projectId,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Safely parse participant names
      Map<String, String> participantNames = {};
      if (data['participantNames'] is Map) {
        final names = data['participantNames'] as Map;
        names.forEach((key, value) {
          participantNames[key.toString()] = value?.toString() ?? 'Unknown User';
        });
      }

      // Safely parse unread count
      Map<String, int> unreadCount = {};
      if (data['unreadCount'] is Map) {
        final counts = data['unreadCount'] as Map;
        counts.forEach((key, value) {
          unreadCount[key.toString()] = (value is int) ? value : 0;
        });
      }

      return ChatRoom(
        id: doc.id,
        participantIds: List<String>.from(data['participantIds'] ?? []),
        participantNames: participantNames,
        lastMessage: data['lastMessage']?.toString(),
        lastMessageTime: data['lastMessageTime'] != null
            ? (data['lastMessageTime'] as Timestamp).toDate()
            : null,
        lastMessageSenderId: data['lastMessageSenderId']?.toString(),
        unreadCount: unreadCount,
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: data['updatedAt'] != null
            ? (data['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
        isActive: data['isActive'] ?? true,
        projectId: data['projectId']?.toString(),
      );
    } catch (e) {
      // Return a fallback chat room if parsing fails
      return ChatRoom(
        id: doc.id,
        participantIds: [],
        participantNames: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null 
          ? Timestamp.fromDate(lastMessageTime!) 
          : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'projectId': projectId,
    };
  }
}