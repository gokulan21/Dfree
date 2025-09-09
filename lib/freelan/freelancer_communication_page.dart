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
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check authentication first
      final isAuthenticated = await _chatService.checkAuthState();
      if (!isAuthenticated) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please log in to access your conversations.';
        });
        return;
      }

      _loadChatRooms();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize chat: ${e.toString()}';
      });
    }
  }

  void _loadChatRooms() {
    try {
      // Listen to chat rooms stream
      _chatService.getUserChatRooms().listen(
        (chatRooms) {
          if (mounted) {
            setState(() {
              _chatRooms = chatRooms;
              _isLoading = false;
              _errorMessage = null;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Error loading conversations: ${error.toString()}';
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load conversations: ${e.toString()}';
        });
      }
    }
  }

  List<ChatRoom> get _filteredChatRooms {
    if (_searchQuery.isEmpty) return _chatRooms;
    
    return _chatRooms.where((chatRoom) {
      final currentUserId = _authService.currentUser?.uid ?? '';
      final otherParticipantId = chatRoom.participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      final otherParticipantName = chatRoom.participantNames[otherParticipantId] ?? '';
      
      return otherParticipantName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (chatRoom.lastMessage ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text(
          'Communication',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Loading conversations...'),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.dangerRed,
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
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
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: const Text(
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
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                prefixIcon: const Icon(Icons.search, color: AppColors.accentCyan),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accentCyan),
                ),
                filled: true,
                fillColor: AppColors.bgSecondary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          
          // Chat list
          Expanded(
            child: _buildChatRoomsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomsList() {
    final filteredChatRooms = _filteredChatRooms;
    
    if (filteredChatRooms.isEmpty && _chatRooms.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
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
                'No conversations yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start a conversation with a client to see it here.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (filteredChatRooms.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.textGrey,
              ),
              SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try searching with different keywords.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: filteredChatRooms.length,
      itemBuilder: (context, index) {
        final chatRoom = filteredChatRooms[index];
        final isSelected = _selectedChatRoom?.id == chatRoom.id;
        
        return _buildChatListItem(chatRoom, isSelected);
      },
    );
  }

  Widget _buildChatListItem(ChatRoom chatRoom, bool isSelected) {
    final currentUserId = _authService.currentUser?.uid ?? '';
    final otherParticipantId = chatRoom.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    final otherParticipantName = chatRoom.participantNames[otherParticipantId] ?? 'Unknown User';
    final unreadCount = chatRoom.unreadCount[currentUserId] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.accentCyan.withOpacity(0.1) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected 
            ? Border.all(color: AppColors.accentCyan.withOpacity(0.3)) 
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _selectedChatRoom = chatRoom;
            });
            // Mark messages as read when chat is opened
            _chatService.markMessagesAsRead(chatRoom.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
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
                      otherParticipantName.isNotEmpty 
                          ? otherParticipantName[0].toUpperCase() 
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              otherParticipantName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chatRoom.lastMessageTime != null)
                            Text(
                              chatRoom.lastMessageTime!.formatTime,
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chatRoom.lastMessage ?? 'No messages yet',
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, 
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.accentPink,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoChatSelected() {
    return Container(
      color: AppColors.bgPrimary,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.textGrey,
            ),
            SizedBox(height: 24),
            Text(
              'Select a conversation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose a conversation from the list to start messaging',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
