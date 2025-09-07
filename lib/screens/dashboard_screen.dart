// dashboard_screen.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets/sidebar.dart';
import '../client/home_page.dart';
import '../client/project_page.dart';
import '../client/communication_page.dart';
import '../client/reports_page.dart';
import '../client/settings_page.dart';
import '../service/firestore_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  
  int selectedIndex = 0;
  String searchQuery = '';
  String selectedProjectFilter = 'all';
  bool isSidebarOpen = false;
  String currentChat = '';
  final TextEditingController messageController = TextEditingController();
  
  List<ChatMessage> chatMessages = [];
  List<Freelancer> freelancers = [];
  List<Project> projects = [];
  Map<String, dynamic> dashboardMetrics = {};
  
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load dashboard metrics
      final metrics = await _firestoreService.getDashboardMetrics();
      setState(() {
        dashboardMetrics = metrics;
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1A3C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33CFFF)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading dashboard...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1A3C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E1A3C),
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            if (!isMobile || isSidebarOpen)
              Container(
                width: isMobile ? screenWidth * 0.8 : (isTablet ? 200 : 250),
                constraints: BoxConstraints(
                  minWidth: isMobile ? 200 : 180,
                  maxWidth: isMobile ? 300 : 280,
                ),
                child: CustomSidebar(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                      if (isMobile) {
                        isSidebarOpen = false;
                      }
                    });
                  },
                ),
              ),
            
            // Overlay for mobile
            if (isMobile && isSidebarOpen)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isSidebarOpen = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              )
            else
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    // Top Bar
                    Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262047),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                            onPressed: () => setState(() => isSidebarOpen = !isSidebarOpen),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _getPageTitle(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () => _showNotifications(),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF33CFFF), Color(0xFFFF1EC0)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 18),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Page Content
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFF1E1A3C),
                        padding: EdgeInsets.all(isMobile ? 12 : 20),
                        child: _buildPageContent(isMobile),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (selectedIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Projects';
      case 2: return 'Communication';
      case 3: return 'Reports';
      case 4: return 'Settings';
      default: return 'Dashboard';
    }
  }

  Widget _buildPageContent(bool isMobile) {
    switch (selectedIndex) {
      case 0:
        return StreamBuilder<List<Freelancer>>(
          stream: _firestoreService.getFreelancers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final freelancers = snapshot.data ?? [];
            return HomePage(
              freelancers: freelancers,
              searchQuery: searchQuery,
              onSearchChanged: (value) => setState(() => searchQuery = value),
              onFreelancerTap: (freelancer) => _showFreelancerDetails(freelancer),
              dashboardMetrics: dashboardMetrics,
            );
          },
        );
        
      case 1:
        return StreamBuilder<List<Project>>(
          stream: _firestoreService.getProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final projects = snapshot.data ?? [];
            return ProjectsPage(
              projects: projects,
              selectedFilter: selectedProjectFilter,
              onFilterChanged: (filter) => setState(() => selectedProjectFilter = filter),
            );
          },
        );
        
      case 2:
        return StreamBuilder<List<Freelancer>>(
          stream: _firestoreService.getFreelancers(),
          builder: (context, snapshot) {
            final freelancers = snapshot.data ?? [];
            if (currentChat.isEmpty && freelancers.isNotEmpty) {
              currentChat = freelancers.first.name;
            }
            
            return CommunicationPage(
              freelancers: freelancers,
              currentChat: currentChat,
              chatMessages: chatMessages,
              messageController: messageController,
              onChatChanged: (name) => _onChatChanged(name),
              onMessageSent: _sendMessage,
            );
          },
        );
        
      case 3:
        return ReportsPage(dashboardMetrics: dashboardMetrics);
        
      case 4:
        return const SettingsPage();
        
      default:
        return const Center(
          child: Text(
            'Page not found',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }

  void _onChatChanged(String name) {
    setState(() {
      currentChat = name;
      chatMessages.clear();
    });
    
    // Load chat messages for the selected freelancer
    _firestoreService.getChatMessages(name).listen((messages) {
      setState(() {
        chatMessages = messages;
      });
    });
  }

  Future<void> _sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isNotEmpty && currentChat.isNotEmpty) {
      try {
        await _firestoreService.sendMessage(currentChat, messageText);
        messageController.clear();
      } catch (e) {
        _showErrorSnackBar('Failed to send message: $e');
      }
    }
  }

  void _showFreelancerDetails(Freelancer freelancer) {
    // Show freelancer modal or navigate to details page
    print('Show details for ${freelancer.name}');
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No new notifications'),
        backgroundColor: Color(0xFF262047),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
