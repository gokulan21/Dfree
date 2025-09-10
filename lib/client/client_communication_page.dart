import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../widgets/chat_widget.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class ClientCommunicationPage extends StatefulWidget {
  const ClientCommunicationPage({super.key});

  @override
  State<ClientCommunicationPage> createState() => _ClientCommunicationPageState();
}

class _ClientCommunicationPageState extends State<ClientCommunicationPage> with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  late TabController _tabController;
  List<ChatRoom> _chatRooms = [];
  List<UserModel> _freelancers = [];
  ChatRoom? _selectedChatRoom;
  bool _isLoading = true;
  bool _isLoadingFreelancers = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChatRooms();
    _loadFreelancers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _loadFreelancers() async {
    setState(() {
      _isLoadingFreelancers = true;
    });
    
    try {
      final freelancers = await _userService.getFreelancers();
      setState(() {
        _freelancers = freelancers;
        _isLoadingFreelancers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFreelancers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading freelancers: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _startChatWithFreelancer(UserModel freelancer) async {
    try {
      final chatId = await _chatService.createOrGetChatRoom(
        freelancer.id, 
        freelancer.name,
      );
      
      final chatRoom = await _chatService.getChatRoom(chatId);
      if (chatRoom != null) {
        setState(() {
          _selectedChatRoom = chatRoom;
          _tabController.index = 0; // Switch to messages tab
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  List<UserModel> get _filteredFreelancers {
    if (_searchQuery.isEmpty) {
      return _freelancers;
    }
    return _freelancers.where((freelancer) =>
        freelancer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (freelancer.email.toLowerCase().contains(_searchQuery.toLowerCase())) ||
        (freelancer.company != null && freelancer.company!.toLowerCase().contains(_searchQuery.toLowerCase()))
    ).toList();
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
      return _buildTabView();
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
        // Sidebar with tabs
        SizedBox(
          width: 350,
          child: _buildTabView(),
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

  Widget _buildTabView() {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Tab Bar
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentCyan, AppColors.accentPink],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textGrey,
                    tabs: const [
                      Tab(text: 'Messages'),
                      Tab(text: 'Freelancers'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search, color: AppColors.accentCyan),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatList(),
                _buildFreelancersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    final filteredChatRooms = _searchQuery.isEmpty 
        ? _chatRooms 
        : _chatRooms.where((chatRoom) {
            final currentUserId = _authService.currentUser?.uid ?? '';
            final otherParticipantId = chatRoom.participantIds.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );
            final otherParticipantName = chatRoom.participantNames[otherParticipantId] ?? 'Unknown';
            return otherParticipantName.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    if (filteredChatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.chat_bubble_outline : Icons.search_off,
              size: 64,
              color: AppColors.textGrey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'No conversations yet'
                  : 'No conversations found',
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 16,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Start a conversation with a freelancer',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filteredChatRooms.length,
      itemBuilder: (context, index) {
        final chatRoom = filteredChatRooms[index];
        final isSelected = _selectedChatRoom?.id == chatRoom.id;
        
        return _buildChatListItem(chatRoom, isSelected);
      },
    );
  }

  Widget _buildFreelancersList() {
    if (_isLoadingFreelancers) {
      return const Center(child: LoadingWidget(message: 'Loading freelancers...'));
    }

    final filteredFreelancers = _filteredFreelancers;

    if (filteredFreelancers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.person_outline : Icons.search_off,
              size: 64,
              color: AppColors.textGrey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'No freelancers available'
                  : 'No freelancers found',
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filteredFreelancers.length,
      itemBuilder: (context, index) {
        final freelancer = filteredFreelancers[index];
        return _buildFreelancerListItem(freelancer);
      },
    );
  }

  Widget _buildFreelancerListItem(UserModel freelancer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
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
              freelancer.name.isNotEmpty ? freelancer.name[0].toUpperCase() : 'F',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          freelancer.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (freelancer.company != null && freelancer.company!.isNotEmpty) ...[
              Text(
                freelancer.company!,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              freelancer.email,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accentCyan, AppColors.accentPink],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Message',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _startChatWithFreelancer(freelancer),
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
              colors: [AppColors.accentCyan, AppColors.accentPink],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              otherParticipantName.isNotEmpty ? otherParticipantName[0].toUpperCase() : 'U',
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
          SizedBox(height: 8),
          Text(
            'Or find a freelancer to start a new conversation',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}