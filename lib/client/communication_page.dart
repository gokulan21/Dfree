// ignore_for_file: deprecated_member_use, prefer_final_fields, prefer_const_constructors, unused_field, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'dart:async';
import '../models.dart';
import '../widgets/card.dart';

class CommunicationPage extends StatefulWidget {
  final List<Freelancer> freelancers;
  final String currentChat;
  final List<ChatMessage> chatMessages;
  final TextEditingController messageController;
  final Function(String) onChatChanged;
  final VoidCallback onMessageSent;

  const CommunicationPage({
    super.key,
    required this.freelancers,
    required this.currentChat,
    required this.chatMessages,
    required this.messageController,
    required this.onChatChanged,
    required this.onMessageSent,
  });

  @override
  State<CommunicationPage> createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage>
    with TickerProviderStateMixin {
  bool _showChatList = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _typingTimer;
  Timer? _statusUpdateTimer;
  bool _isTyping = false;
  final ScrollController _chatScrollController = ScrollController();
  Map<String, int> _unreadCounts = {};
  Map<String, DateTime> _lastSeen = {};
  Map<String, bool> _onlineStatus = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    // Initialize dynamic data
    _initializeDynamicData();
    
    // Start fade animation
    _fadeController.forward();
  }

  void _initializeDynamicData() {
    // Initialize unread counts and online status for each freelancer
    for (final freelancer in widget.freelancers) {
      _unreadCounts[freelancer.name] = _generateRandomUnreadCount();
      _onlineStatus[freelancer.name] = _generateRandomOnlineStatus();
      _lastSeen[freelancer.name] = _generateRandomLastSeen();
    }
    
    // Simulate real-time updates
    _startRealTimeUpdates();
  }

  void _startRealTimeUpdates() {
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // Randomly update online status
          for (final freelancer in widget.freelancers) {
            if (DateTime.now().millisecondsSinceEpoch % 7 == 0) {
              _onlineStatus[freelancer.name] = !_onlineStatus[freelancer.name]!;
              if (!_onlineStatus[freelancer.name]!) {
                _lastSeen[freelancer.name] = DateTime.now();
              }
            }
          }
        });
      }
    });
  }

  int _generateRandomUnreadCount() {
    final random = DateTime.now().millisecondsSinceEpoch % 6;
    return random == 0 ? 0 : random;
  }

  bool _generateRandomOnlineStatus() {
    return DateTime.now().millisecondsSinceEpoch % 3 != 0;
  }

  DateTime _generateRandomLastSeen() {
    final now = DateTime.now();
    final minutesAgo = DateTime.now().millisecondsSinceEpoch % 120;
    return now.subtract(Duration(minutes: minutesAgo));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    _messageFocusNode.dispose();
    _typingTimer?.cancel();
    _statusUpdateTimer?.cancel();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _handleTyping() {
    if (!_isTyping) {
      setState(() {
        _isTyping = true;
      });
    }
    
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF1E1A3C),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;
              final isMobile = screenWidth < 768;
              final isTablet = screenWidth >= 768 && screenWidth < 1024;
              final isDesktop = screenWidth >= 1024;
              
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildResponsiveLayout(
                  isMobile: isMobile,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout({
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required double screenWidth,
    required double screenHeight,
  }) {
    if (isMobile) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout(
        isTablet: isTablet,
        isDesktop: isDesktop,
        screenWidth: screenWidth,
      );
    }
  }

  Widget _buildDesktopLayout({
    required bool isTablet,
    required bool isDesktop,
    required double screenWidth,
  }) {
    final chatListFlex = isDesktop ? 2 : 3;
    final chatWindowFlex = isDesktop ? 3 : 4;
    final padding = isDesktop ? 20.0 : 16.0;
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dynamic Chat List
          Expanded(
            flex: chatListFlex,
            child: Container(
              constraints: BoxConstraints(
                minWidth: isDesktop ? 320 : 280,
                maxWidth: isDesktop ? 450 : 380,
              ),
              child: _buildDynamicChatList(isDesktop: isDesktop),
            ),
          ),
          SizedBox(width: padding),
          // Dynamic Chat Window
          Expanded(
            flex: chatWindowFlex,
            child: _buildDynamicChatWindow(isDesktop: isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      child: _showChatList
          ? _buildMobileChatList()
          : _buildMobileChatWindow(),
    );
  }

  Widget _buildDynamicChatList({bool isDesktop = false}) {
    final filteredFreelancers = _getFilteredFreelancers();
    final totalUnread = _getTotalUnreadCount();
    
    return DashboardCard(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic header with stats
            _buildChatListHeader(totalUnread, isDesktop),
            SizedBox(height: isDesktop ? 20 : 16),
            
            // Dynamic search bar
            _buildSearchBar(isDesktop),
            SizedBox(height: isDesktop ? 20 : 16),
            
            // Dynamic chat list with animations
            Expanded(
              child: _buildAnimatedChatList(filteredFreelancers, isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatListHeader(int totalUnread, bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Active Conversations",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 22 : 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${widget.freelancers.length} contacts • ${_getOnlineCount()} online",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: isDesktop ? 14 : 12,
                ),
              ),
            ],
          ),
        ),
        if (totalUnread > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF1EC0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              totalUnread > 99 ? '99+' : totalUnread.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar(bool isDesktop) {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: "Search conversations...",
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: Icon(Icons.clear, color: Colors.grey[400]),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF151229),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF33CFFF)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16 : 12,
          vertical: isDesktop ? 14 : 12,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildAnimatedChatList(List<Freelancer> filteredFreelancers, bool isDesktop) {
    if (filteredFreelancers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              "No conversations found",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Text("Clear search"),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredFreelancers.length,
      itemBuilder: (context, index) {
        final freelancer = filteredFreelancers[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 200 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: DynamicChatListItem(
                  freelancer: freelancer,
                  isActive: widget.currentChat == freelancer.name,
                  unreadCount: _unreadCounts[freelancer.name] ?? 0,
                  isOnline: _onlineStatus[freelancer.name] ?? false,
                  lastSeen: _lastSeen[freelancer.name],
                  onTap: () {
                    widget.onChatChanged(freelancer.name);
                    setState(() {
                      _unreadCounts[freelancer.name] = 0;
                      if (!isDesktop) {
                        _showChatList = false;
                        _slideController.forward();
                      }
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMobileChatList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildDynamicChatList(),
    );
  }

  Widget _buildMobileChatWindow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildDynamicChatWindow(),
    );
  }

  Widget _buildDynamicChatWindow({bool isDesktop = false}) {
    final currentFreelancer = widget.freelancers
        .where((f) => f.name == widget.currentChat)
        .firstOrNull;
    
    return DashboardCard(
      child: Column(
        children: [
          // Dynamic chat header
          _buildDynamicChatHeader(currentFreelancer, isDesktop),
          
          // Typing indicator
          if (_isTyping) _buildTypingIndicator(),
          
          // Messages with enhanced animations
          Expanded(
            child: _buildMessagesArea(isDesktop),
          ),
          
          // Enhanced message input
          _buildDynamicMessageInput(isDesktop),
        ],
      ),
    );
  }

  Widget _buildDynamicChatHeader(Freelancer? freelancer, bool isDesktop) {
    final isOnline = freelancer != null ? _onlineStatus[freelancer.name] ?? false : false;
    final lastSeen = freelancer != null ? _lastSeen[freelancer.name] : null;
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _showChatList = true;
                });
                _slideController.reverse();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
          ],
          
          // Avatar with online indicator
          Stack(
            children: [
              Container(
                width: isDesktop ? 48 : 40,
                height: isDesktop ? 48 : 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF33CFFF), Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    widget.currentChat.isNotEmpty ? widget.currentChat[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 18 : 16,
                    ),
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFF1E1A3C),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.currentChat,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline 
                      ? "Online" 
                      : lastSeen != null 
                          ? "Last seen ${_formatLastSeen(lastSeen)}"
                          : "Offline",
                  style: TextStyle(
                    color: isOnline ? Colors.green : Colors.grey[400],
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Implement voice call
                },
                icon: const Icon(Icons.call, color: Colors.white, size: 20),
              ),
              IconButton(
                onPressed: () {
                  // Implement video call
                },
                icon: const Icon(Icons.videocam, color: Colors.white, size: 20),
              ),
              if (isDesktop)
                IconButton(
                  onPressed: () {
                    // Implement more options
                  },
                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 1),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: (value * 2) % 1,
                child: Text(
                  "${widget.currentChat} is typing...",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea(bool isDesktop) {
    if (widget.chatMessages.isEmpty) {
      return _buildEmptyMessagesState(isDesktop);
    }

    return ListView.builder(
      controller: _chatScrollController,
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      itemCount: widget.chatMessages.length,
      itemBuilder: (context, index) {
        final message = widget.chatMessages[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: DynamicChatMessageWidget(
                  message: message,
                  isDesktop: isDesktop,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyMessagesState(bool isDesktop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isDesktop ? 80 : 64,
            height: isDesktop ? 80 : 64,
            decoration: BoxDecoration(
              color: const Color(0xFF33CFFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: isDesktop ? 40 : 32,
              color: const Color(0xFF33CFFF),
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 16),
          Text(
            "Start a conversation",
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isDesktop ? 12 : 8),
          Text(
            "Send a message to ${widget.currentChat} to get started",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: isDesktop ? 16 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicMessageInput(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          IconButton(
            onPressed: () {
              // Implement file attachment
            },
            icon: const Icon(Icons.attach_file, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF151229),
              padding: const EdgeInsets.all(12),
              minimumSize: const Size(44, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Message input
          Expanded(
            child: TextField(
              controller: widget.messageController,
              focusNode: _messageFocusNode,
              maxLines: isDesktop ? 6 : 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onChanged: (value) {
                _handleTyping();
              },
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF151229),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF33CFFF)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 12,
                  vertical: isDesktop ? 16 : 12,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) {
                widget.onMessageSent();
                _scrollToBottom();
              },
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              onPressed: () {
                widget.onMessageSent();
                _scrollToBottom();
              },
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFF1EC0),
                padding: const EdgeInsets.all(12),
                minimumSize: const Size(44, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Freelancer> _getFilteredFreelancers() {
    if (_searchQuery.isEmpty) return widget.freelancers;
    
    return widget.freelancers.where((freelancer) {
      return freelancer.name.toLowerCase().contains(_searchQuery) ||
             freelancer.role.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  int _getTotalUnreadCount() {
    return _unreadCounts.values.fold(0, (sum, count) => sum + count);
  }

  int _getOnlineCount() {
    return _onlineStatus.values.where((status) => status).length;
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return "just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }
}

class DynamicChatListItem extends StatefulWidget {
  final Freelancer freelancer;
  final bool isActive;
  final int unreadCount;
  final bool isOnline;
  final DateTime? lastSeen;
  final VoidCallback onTap;

  const DynamicChatListItem({
    super.key,
    required this.freelancer,
    required this.isActive,
    required this.unreadCount,
    required this.isOnline,
    required this.lastSeen,
    required this.onTap,
  });

  @override
  State<DynamicChatListItem> createState() => _DynamicChatListItemState();
}

class _DynamicChatListItemState extends State<DynamicChatListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.unreadCount > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(DynamicChatListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unreadCount > 0 && oldWidget.unreadCount == 0) {
      _pulseController.repeat(reverse: true);
    } else if (widget.unreadCount == 0 && oldWidget.unreadCount > 0) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? const Color(0xFF33CFFF).withOpacity(0.15)
                  : Colors.grey[800]?.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: widget.isActive
                  ? Border.all(color: const Color(0xFF33CFFF).withOpacity(0.4))
                  : null,
            ),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isActive 
                              ? [const Color(0xFF33CFFF), Colors.blue]
                              : [Colors.grey[600]!, Colors.grey[700]!],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          widget.freelancer.name.isNotEmpty 
                              ? widget.freelancer.name[0].toUpperCase() 
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    if (widget.isOnline)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF1E1A3C),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.freelancer.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: widget.isActive ? 16 : 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (widget.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF1EC0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      widget.unreadCount > 99 
                                          ? '99+' 
                                          : widget.unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.freelancer.role,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (!widget.isOnline && widget.lastSeen != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatLastSeen(widget.lastSeen!),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
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

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return "now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h";
    } else {
      return "${difference.inDays}d";
    }
  }
}

class DynamicChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  final bool isDesktop;

  const DynamicChatMessageWidget({
    super.key,
    required this.message,
    this.isDesktop = false,
  });

  @override
  State<DynamicChatMessageWidget> createState() => _DynamicChatMessageWidgetState();
}

class _DynamicChatMessageWidgetState extends State<DynamicChatMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _messageController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _showTime = false;

  @override
  void initState() {
    super.initState();
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: widget.message.isReceived 
          ? const Offset(-0.3, 0.0) 
          : const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeIn,
    ));

    _messageController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showTime = !_showTime;
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: widget.isDesktop ? 20 : 16),
            child: Row(
              mainAxisAlignment: widget.message.isReceived
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.message.isReceived) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: _buildEnhancedMessageBubble(),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                ] else ...[
                  const Expanded(flex: 1, child: SizedBox()),
                  Flexible(
                    child: _buildEnhancedMessageBubble(),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMessageBubble() {
    return Column(
      crossAxisAlignment: widget.message.isReceived 
          ? CrossAxisAlignment.start 
          : CrossAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: BoxConstraints(
            maxWidth: widget.isDesktop ? 400 : 300,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isDesktop ? 20 : 16,
            vertical: widget.isDesktop ? 16 : 12,
          ),
          decoration: BoxDecoration(
            gradient: widget.message.isReceived
                ? LinearGradient(
                    colors: [
                      const Color(0xFF262047),
                      const Color(0xFF1E1A3C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFFFF1EC0),
                      const Color(0xFFFF0A9B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: widget.message.isReceived
                  ? const Radius.circular(20)
                  : const Radius.circular(6),
              bottomLeft: widget.message.isReceived
                  ? const Radius.circular(6)
                  : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.message.isReceived 
                    ? Colors.black 
                    : const Color(0xFFFF1EC0)).withOpacity(0.2),
                blurRadius: widget.isDesktop ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.message.message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isDesktop ? 16 : 14,
                  height: 1.4,
                ),
                softWrap: true,
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.message.time,
                    style: TextStyle(
                      color: widget.message.isReceived
                          ? Colors.grey[400]
                          : Colors.grey[200],
                      fontSize: widget.isDesktop ? 12 : 11,
                    ),
                  ),
                  
                  if (!widget.message.isReceived) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all,
                      size: widget.isDesktop ? 14 : 12,
                      color: Colors.grey[200],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // Show timestamp on tap
        if (_showTime)
          AnimatedOpacity(
            opacity: _showTime ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Delivered ${widget.message.time}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}