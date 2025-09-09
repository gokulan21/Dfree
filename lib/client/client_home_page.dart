// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/project_card.dart';
import '../../widgets/freelancer_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  
  Map<String, dynamic> _dashboardMetrics = {};
  List<ProjectModel> _recentProjects = [];
  List<UserModel> _topFreelancers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Load dashboard metrics
        final metrics = await _firestoreService.getClientDashboardMetrics(currentUser.uid);
        
        // Load recent projects - using getUserProjects and filtering by clientId
        final projectsStream = _firestoreService.getUserProjects(currentUser.uid);
        final projectsSnapshot = await projectsStream.first;
        final clientProjects = projectsSnapshot.toList();
        
        // Load top freelancers
        final freelancersStream = _firestoreService.getFreelancers();
        final freelancersSnapshot = await freelancersStream.first;
        
        if (mounted) {
          setState(() {
            _dashboardMetrics = metrics;
            _recentProjects = clientProjects.take(5).toList();
            _topFreelancers = freelancersSnapshot.take(4).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: ${e.toString()}'),
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

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width < 768 ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            
            // Metrics Cards
            _buildMetricsSection(),
            const SizedBox(height: 24),
            
            // Recent Projects and Top Freelancers
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1024) {
                  return Column(
                    children: [
                      _buildRecentProjects(),
                      const SizedBox(height: 24),
                      _buildTopFreelancers(),
                    ],
                  );
                } else {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildRecentProjects()),
                        const SizedBox(width: 24),
                        Expanded(child: _buildTopFreelancers()),
                      ],
                    ),
                  );
                }
              },
            ),
            // Add bottom padding for scroll
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return CustomCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accentCyan, AppColors.accentPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your projects and find the best freelancers',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildMetricsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        double childAspectRatio = 1.3;
        
        if (constraints.maxWidth < 480) {
          crossAxisCount = 2;
          childAspectRatio = 1.1;
        } else if (constraints.maxWidth < 768) {
          crossAxisCount = 2;
          childAspectRatio = 1.2;
        }
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _buildMetricCard(
              'Total Projects',
              _dashboardMetrics['totalProjects']?.toString() ?? '0',
              Icons.folder_outlined,
              AppColors.accentCyan,
            ),
            _buildMetricCard(
              'Active Projects',
              _dashboardMetrics['activeProjects']?.toString() ?? '0',
              Icons.work_outline,
              AppColors.accentPink,
            ),
            _buildMetricCard(
              'Completed',
              _dashboardMetrics['completedProjects']?.toString() ?? '0',
              Icons.check_circle_outline,
              AppColors.successGreen,
            ),
            _buildMetricCard(
              'Total Budget',
              '\$${(_dashboardMetrics['totalBudget'] ?? 0.0).toStringAsFixed(0)}',
              Icons.attach_money,
              AppColors.warningYellow,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 24),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProjects() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Recent Projects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to projects page
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recentProjects.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No projects yet. Create your first project!',
                    style: TextStyle(color: AppColors.textGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentProjects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return ProjectCard(
                    project: _recentProjects[index],
                    onTap: () {
                      // Navigate to project detail
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFreelancers() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Top Freelancers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to freelancers page
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_topFreelancers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No freelancers available.',
                    style: TextStyle(color: AppColors.textGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _topFreelancers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return FreelancerCard(
                    freelancer: _topFreelancers[index],
                    onTap: () {
                      // Navigate to freelancer detail
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}