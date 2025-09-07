// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets/sidebar.dart';
import '../client/home_page.dart';
import '../client/project_page.dart';
import '../client/communication_page.dart';
import '../client/reports_page.dart';
import '../client/settings_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  String searchQuery = '';
  String selectedProjectFilter = 'all';
  bool isSidebarOpen = false;
  String currentChat = 'Gokul';
  final TextEditingController messageController = TextEditingController();
  
  final List<ChatMessage> chatMessages = [
    ChatMessage(
      message: "Hi! I've completed the homepage design. Could you please review it?",
      isReceived: true,
      time: "10:30 AM",
    ),
    ChatMessage(
      message: "Great work! The design looks amazing. Just a small change needed in the hero section.",
      isReceived: false,
      time: "10:35 AM",
    ),
    ChatMessage(
      message: "Sure! I'll make those changes right away. Should I also update the color scheme?",
      isReceived: true,
      time: "10:40 AM",
    ),
    ChatMessage(
      message: "Yes, please use the brand colors we discussed. Looking forward to the final version!",
      isReceived: false,
      time: "10:45 AM",
    ),
  ];

  final List<Freelancer> freelancers = [
    Freelancer(
      name: "Gokul",
      role: "UI/UX Designer",
      rating: 5.0,
      skills: ["Figma", "Adobe XD", "Photoshop"],
      workload: 75,
      email: "gokul@email.com",
      phone: "+1 (555) 123-4567",
      bio: "3 years experience in UI/UX design with focus on modern web applications. Specialized in user research and creating intuitive interfaces.",
    ),
    Freelancer(
      name: "Mohana",
      role: "Backend Developer",
      rating: 4.8,
      skills: ["Node.js", "Python", "MongoDB"],
      workload: 60,
      email: "mohana@email.com",
      phone: "+1 (555) 234-5678",
      bio: "Senior backend developer with expertise in scalable web applications and database design. 5 years of experience in server-side development.",
    ),
    Freelancer(
      name: "Sarah",
      role: "Frontend Developer",
      rating: 4.9,
      skills: ["React", "Vue.js", "TypeScript"],
      workload: 45,
      email: "sarah@email.com",
      phone: "+1 (555) 345-6789",
      bio: "Frontend specialist with strong background in modern JavaScript frameworks. Expert in creating responsive and interactive web applications.",
    ),
    Freelancer(
      name: "Alex",
      role: "Full Stack Developer",
      rating: 4.7,
      skills: ["React", "Node.js", "AWS"],
      workload: 80,
      email: "alex@email.com",
      phone: "+1 (555) 456-7890",
      bio: "Full-stack developer with comprehensive knowledge of both frontend and backend technologies. AWS certified with cloud deployment expertise.",
    ),
  ];

  final List<Project> projects = [
    Project(
      name: "E-commerce Website",
      assignee: "Gokul",
      dueDate: "Dec 25, 2024",
      status: ProjectStatus.inProgress,
      progress: 85,
      priority: Priority.high,
      description: "A comprehensive e-commerce platform with modern design and robust backend functionality. Features include user authentication, product catalog, shopping cart, payment integration, and admin dashboard.",
    ),
    Project(
      name: "Mobile App Backend",
      assignee: "Mohana",
      dueDate: "Jan 15, 2025",
      status: ProjectStatus.inProgress,
      progress: 60,
      priority: Priority.medium,
      description: "Backend API development for mobile application including user management, data synchronization, push notifications, and third-party integrations. Built with Node.js and MongoDB.",
    ),
    Project(
      name: "Brand Identity Design",
      assignee: "Sarah",
      dueDate: "Dec 20, 2024",
      status: ProjectStatus.overdue,
      progress: 95,
      priority: Priority.high,
      description: "Complete brand identity package including logo design, color palette, typography, business cards, letterheads, and brand guidelines. Project is 95% complete with final revisions pending.",
    ),
    Project(
      name: "Dashboard Analytics",
      assignee: "Alex",
      dueDate: "Jan 30, 2025",
      status: ProjectStatus.completed,
      progress: 100,
      priority: Priority.low,
      description: "Advanced analytics dashboard with real-time data visualization, custom reporting, and interactive charts. Successfully delivered ahead of schedule with all requirements met.",
    ),
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E1A3C),
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar - Responsive visibility
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
                        isSidebarOpen = false; // Auto-close on mobile after selection
                      }
                    });
                  },
                ),
              ),
            
            // Overlay for mobile when sidebar is open
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Menu Button
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                            onPressed: () => setState(() => isSidebarOpen = !isSidebarOpen),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                          
                          // Page Title
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
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                          
                          const Spacer(),
                          
                          // SEARCH ICON REMOVED - No more search button for mobile
                          
                          // Notification Button
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                            onPressed: () => _showNotifications(),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                          
                          // Profile Button - Only shows on desktop/tablet
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
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
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
      case 0:
        return 'Dashboard';
      case 1:
        return 'Projects';
      case 2:
        return 'Communication';
      case 3:
        return 'Reports';
      case 4:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildPageContent(bool isMobile) {
    try {
      switch (selectedIndex) {
        case 0:
          return HomePage(
            freelancers: freelancers,
            searchQuery: searchQuery,
            onSearchChanged: (value) => setState(() => searchQuery = value), 
            onFreelancerTap: (Freelancer freelancer) {},
          );
        case 1:
          return ProjectsPage(
            projects: projects,
            selectedFilter: selectedProjectFilter,
            onFilterChanged: (filter) => setState(() => selectedProjectFilter = filter),
          );
        case 2:
          return CommunicationPage(
            freelancers: freelancers,
            currentChat: currentChat,
            chatMessages: chatMessages,
            messageController: messageController,
            onChatChanged: (name) => setState(() => currentChat = name),
            onMessageSent: _sendMessage,
          );
        case 3:
          return const ReportsPage();
        case 4:
          return const SettingsPage();
        default:
          return HomePage(
            freelancers: freelancers,
            searchQuery: searchQuery,
            onSearchChanged: (value) => setState(() => searchQuery = value), 
            onFreelancerTap: (Freelancer freelancer) {},
          );
      }
    } catch (e) {
      // Error fallback
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading page',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again or contact support',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => selectedIndex = 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF33CFFF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      );
    }
  }

  void _sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isNotEmpty) {
      setState(() {
        chatMessages.add(ChatMessage(
          message: messageText,
          isReceived: false,
          time: _getCurrentTimeString(),
        ));
        messageController.clear();
      });
    }
  }

  String _getCurrentTimeString() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('No new notifications'),
        backgroundColor: const Color(0xFF262047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}