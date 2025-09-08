import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Create or get chat room
  Future<String> createOrGetChatRoom(String otherUserId, String otherUserName, {String? projectId}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Generate chat room ID
      final participants = [_currentUserId, otherUserId];
      participants.sort();
      final chatId = participants.join('_');

      // Check if chat room exists
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        // Create new chat room
        final chatRoom = ChatRoom(
          id: chatId,
          participantIds: [_currentUserId, otherUserId],
          participantNames: {
            _currentUserId: currentUser.displayName ?? 'User',
            otherUserId: otherUserName,
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          projectId: projectId,
        );

        await _firestore.collection('chats').doc(chatId).set(chatRoom.toFirestore());
      }

      return chatId;
    } catch (e) {
      throw Exception('Failed to create chat room: ${e.toString()}');
    }
  }

  // Send message
  Future<void> sendMessage(String chatId, String message, {MessageType type = MessageType.text, String? fileUrl, String? fileName}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final chatMessage = ChatMessage(
        id: '',
        chatId: chatId,
        senderId: _currentUserId,
        senderName: currentUser.displayName ?? 'User',
        message: message,
        type: type,
        fileUrl: fileUrl,
        fileName: fileName,
        timestamp: DateTime.now(),
      );

      // Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(chatMessage.toFirestore());

      // Update chat room with last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': _currentUserId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update unread count for other participants
      final chatRoom = await getChatRoom(chatId);
      if (chatRoom != null) {
        final otherParticipants = chatRoom.participantIds.where((id) => id != _currentUserId);
        Map<String, int> newUnreadCount = Map.from(chatRoom.unreadCount);
        
        for (String participantId in otherParticipants) {
          newUnreadCount[participantId] = (newUnreadCount[participantId] ?? 0) + 1;
        }

        await _firestore.collection('chats').doc(chatId).update({
          'unreadCount': newUnreadCount,
        });
      }
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  // Get chat room
  Future<ChatRoom?> getChatRoom(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        return ChatRoom.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get chat room: ${e.toString()}');
    }
  }

  // Get messages for a chat
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  // Get user's chat rooms
  Stream<List<ChatRoom>> getUserChatRooms() {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: _currentUserId)
        .where('isActive', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromFirestore(doc))
            .toList());
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      // Update unread count
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$_currentUserId': 0,
      });

      // Mark messages as read
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: _currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: ${e.toString()}');
    }
  }

  // Delete chat room
  Future<void> deleteChatRoom(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete chat room: ${e.toString()}');
    }
  }

  // Search messages
  Future<List<ChatMessage>> searchMessages(String chatId, String query) async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return messages.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .where((message) => message.message.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  // Get unread message count for user
  Future<int> getUnreadMessageCount() async {
    try {
      final chatRooms = await _firestore
          .collection('chats')
          .where('participantIds', arrayContains: _currentUserId)
          .where('isActive', isEqualTo: true)
          .get();

      int totalUnread = 0;
      for (var doc in chatRooms.docs) {
        final chatRoom = ChatRoom.fromFirestore(doc);
        totalUnread += chatRoom.unreadCount[_currentUserId] ?? 0;
      }

      return totalUnread;
    } catch (e) {
      return 0;
    }
  }
}
