import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../models/chat_model.dart';
import '../../widgets/chat_widget.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class FreelancerCommunicationPage extends StatefulWidget {
  const FreelancerCommunicationPage({super.key});

  @override
  State<FreelancerCommunicationPage> createState() => _FreelancerCommunicationPageState();
}

class _FreelancerCommunicationPageState extends State<FreelancerCommunicationPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  
  List<ChatRoom> _chatRooms = [];
  ChatRoom? _selectedChatRoom;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    try {
      _chatService.getUserChatRooms().listen((chatRooms) {
        setState(() {
          _chatRooms = chatRooms;
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading chats: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        if (isMobile) {
          return _buildMobileLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    if (_selectedChatRoom == null) {
      return _buildChatList();
    } else {
      return ChatWidget(
        chatRoom: _selectedChatRoom!,
        onBack: () {
          setState(() {
            _selectedChatRoom = null;
          });
        },
      );
    }
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Chat list
        SizedBox(
          width: 350,
          child: _buildChatList(),
        ),
        
        // Chat area
        Expanded(
          child: _selectedChatRoom != null
              ? ChatWidget(chatRoom: _selectedChatRoom!)
              : _buildNoChatSelected(),
        ),
      ],
    );
  }

  Widget _buildChatList() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Messages',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: Icon(Icons.search, color: AppColors.accentCyan),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                // Implement search functionality
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Chat list
          Expanded(
            child: _chatRooms.isEmpty
                ? const Center(
                    child: Text(
                      'No conversations yet',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _chatRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = _chatRooms[index];
                      final isSelected = _selectedChatRoom?.id == chatRoom.id;
                      
                      return _buildChatListItem(chatRoom, isSelected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListItem(ChatRoom chatRoom, bool isSelected) {
    final currentUserId = _authService.currentUser?.uid ?? '';
    final otherParticipantId = chatRoom.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    final otherParticipantName = chatRoom.participantNames[otherParticipantId] ?? 'Unknown';
    final unreadCount = chatRoom.unreadCount[currentUserId] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentCyan.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: AppColors.accentCyan.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accentPink, AppColors.accentCyan],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              otherParticipantName.isNotEmpty ? otherParticipantName[0].toUpperCase() : 'C',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          otherParticipantName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          chatRoom.lastMessage ?? 'No messages yet',
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (chatRoom.lastMessageTime != null)
              Text(
                chatRoom.lastMessageTime!.formatTime,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
            if (unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.accentPink,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          setState(() {
            _selectedChatRoom = chatRoom;
          });
          _chatService.markMessagesAsRead(chatRoom.id);
        },
      ),
    );
  }

  Widget _buildNoChatSelected() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textGrey,
          ),
          SizedBox(height: 16),
          Text(
            'Select a conversation to start messaging',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
