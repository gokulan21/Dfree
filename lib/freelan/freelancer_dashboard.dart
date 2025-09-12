import 'package:flutter/material.dart';
import 'freelancer_home_page.dart';
import 'freelancer_projects_page.dart';
import 'freelancer_clients_page.dart';
import 'freelancer_communication_page.dart';
import 'freelancer_reports_page.dart';
import 'freelancer_settings_page.dart';
import '../../widgets/custom_sidebar.dart';
import '../../utils/constants.dart';

class FreelancerDashboard extends StatefulWidget {
  const FreelancerDashboard({super.key});

  @override
  State<FreelancerDashboard> createState() => _FreelancerDashboardState();
}

class _FreelancerDashboardState extends State<FreelancerDashboard> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const FreelancerHomePage(),
    const FreelancerProjectsPage(),
    const FreelancerClientsPage(),
    const FreelancerCommunicationPage(),
    const FreelancerReportsPage(),
    const FreelancerSettingsPage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'My Projects',
    'My Clients',
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
      body: SafeArea( // Add SafeArea to prevent overflow issues
        child: Row(
          children: [
            if (isDesktop)
              CustomSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                userRole: 'freelancer',
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
      ),
    );
  }

  Widget _buildAppBar(bool isDesktop) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16, // Responsive padding
      ),
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
              padding: EdgeInsets.zero, // Reduce button padding
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          if (!isDesktop) const SizedBox(width: 8),
          Expanded( // Use Expanded to prevent overflow
            child: Text(
              _titles[_selectedIndex],
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop ? 20 : 18, // Responsive font size
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.bgSecondary,
      width: MediaQuery.of(context).size.width * 0.8, // Responsive width
      child: CustomSidebar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
        userRole: 'freelancer',
      ),
    );
  }
}