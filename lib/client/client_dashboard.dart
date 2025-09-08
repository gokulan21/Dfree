import 'package:flutter/material.dart';
import 'client_home_page.dart';
import 'client_projects_page.dart';
import 'client_freelancers_page.dart';
import 'client_communication_page.dart';
import 'client_reports_page.dart';
import 'client_settings_page.dart';
import '../../widgets/custom_sidebar.dart';
import '../../utils/constants.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const ClientHomePage(),
    const ClientProjectsPage(),
    const ClientFreelancersPage(),
    const ClientCommunicationPage(),
    const ClientReportsPage(),
    const ClientSettingsPage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Projects',
    'Freelancers',
    'Communication',
    'Reports',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgPrimary,
      drawer: !isDesktop ? _buildDrawer() : null,
      body: Row(
        children: [
          if (isDesktop)
            CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              userRole: 'client',
            ),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(isDesktop),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDesktop) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          const SizedBox(width: 16),
          Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentCyan, AppColors.accentPink],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.bgSecondary,
      child: CustomSidebar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
        userRole: 'client',
      ),
    );
  }
}
