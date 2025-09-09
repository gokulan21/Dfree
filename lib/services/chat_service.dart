// ignore_for_file: avoid_print

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

      if (_currentUserId.isEmpty) {
        throw Exception('Current user ID is empty');
      }

      // Generate chat room ID
      final participants = [_currentUserId, otherUserId];
      participants.sort();
      final chatId = participants.join('_');

      // Check if chat room exists
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        // Get current user data for name
        final currentUserDoc = await _firestore.collection('users').doc(_currentUserId).get();
        final currentUserName = currentUserDoc.exists 
            ? (currentUserDoc.data()?['name'] ?? currentUser.displayName ?? 'User')
            : (currentUser.displayName ?? 'User');

        // Create new chat room
        final chatRoom = ChatRoom(
          id: chatId,
          participantIds: [_currentUserId, otherUserId],
          participantNames: {
            _currentUserId: currentUserName,
            otherUserId: otherUserName,
          },
          unreadCount: {
            _currentUserId: 0,
            otherUserId: 0,
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

      if (_currentUserId.isEmpty) {
        throw Exception('Current user ID is empty');
      }

      if (message.trim().isEmpty && type == MessageType.text) {
        throw Exception('Message cannot be empty');
      }

      // Get current user name
      final currentUserDoc = await _firestore.collection('users').doc(_currentUserId).get();
      final currentUserName = currentUserDoc.exists 
          ? (currentUserDoc.data()?['name'] ?? currentUser.displayName ?? 'User')
          : (currentUser.displayName ?? 'User');

      final chatMessage = ChatMessage(
        id: '',
        chatId: chatId,
        senderId: _currentUserId,
        senderName: currentUserName,
        message: message.trim(),
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
        'lastMessage': message.trim(),
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
    try {
      return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
            try {
              return snapshot.docs
                  .map((doc) => ChatMessage.fromFirestore(doc))
                  .toList();
            } catch (e) {
              print('Error parsing messages: $e');
              return <ChatMessage>[];
            }
          });
    } catch (e) {
      print('Error getting messages stream: $e');
      return Stream.value(<ChatMessage>[]);
    }
  }

  // Get user's chat rooms - FIXED VERSION
  Stream<List<ChatRoom>> getUserChatRooms() {
    try {
      if (_currentUserId.isEmpty) {
        print('Warning: Current user ID is empty');
        return Stream.value(<ChatRoom>[]);
      }

      // Simplified query to avoid composite index requirement
      return _firestore
          .collection('chats')
          .where('participantIds', arrayContains: _currentUserId)
          .snapshots()
          .map((snapshot) {
            try {
              List<ChatRoom> chatRooms = snapshot.docs
                  .map((doc) {
                    try {
                      return ChatRoom.fromFirestore(doc);
                    } catch (e) {
                      print('Error parsing chat room ${doc.id}: $e');
                      return null;
                    }
                  })
                  .where((chatRoom) => chatRoom != null && chatRoom.isActive)
                  .cast<ChatRoom>()
                  .toList();

              // Sort by updatedAt in Dart instead of Firestore
              chatRooms.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              
              return chatRooms;
            } catch (e) {
              print('Error parsing chat rooms: $e');
              return <ChatRoom>[];
            }
          });
    } catch (e) {
      print('Error getting chat rooms stream: $e');
      return Stream.value(<ChatRoom>[]);
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      if (_currentUserId.isEmpty) {
        throw Exception('Current user ID is empty');
      }

      // Update unread count
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$_currentUserId': 0,
      });

      // Mark messages as read (batch operation for better performance)
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: _currentUserId)
          .where('isRead', isEqualTo: false)
          .limit(100) // Limit to avoid large batches
          .get();

      if (unreadMessages.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (var doc in unreadMessages.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error marking messages as read: $e');
      // Don't throw here to avoid breaking the UI
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
      if (query.trim().isEmpty) return [];

      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return messages.docs
          .map((doc) {
            try {
              return ChatMessage.fromFirestore(doc);
            } catch (e) {
              print('Error parsing message in search: $e');
              return null;
            }
          })
          .where((message) => message != null)
          .cast<ChatMessage>()
          .where((message) => message.message.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  // Get unread message count for user
  Future<int> getUnreadMessageCount() async {
    try {
      if (_currentUserId.isEmpty) return 0;

      final chatRooms = await _firestore
          .collection('chats')
          .where('participantIds', arrayContains: _currentUserId)
          .get();

      int totalUnread = 0;
      for (var doc in chatRooms.docs) {
        try {
          final chatRoom = ChatRoom.fromFirestore(doc);
          if (chatRoom.isActive) {
            totalUnread += chatRoom.unreadCount[_currentUserId] ?? 0;
          }
        } catch (e) {
          print('Error parsing chat room for unread count: $e');
        }
      }

      return totalUnread;
    } catch (e) {
      print('Error getting unread message count: $e');
      return 0;
    }
  }

  // Check if user is authenticated and has valid ID
  bool get isUserAuthenticated {
    return _auth.currentUser != null && _currentUserId.isNotEmpty;
  }

  // Initialize or refresh authentication state
  Future<bool> checkAuthState() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Refresh token if needed
        await user.reload();
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking auth state: $e');
      return false;
    }
  }
}
