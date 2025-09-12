// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/project_service.dart';
import '../../models/project_model.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/project_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class FreelancerHomePage extends StatefulWidget {
  const FreelancerHomePage({super.key});

  @override
  State<FreelancerHomePage> createState() => _FreelancerHomePageState();
}

class _FreelancerHomePageState extends State<FreelancerHomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final ProjectService _projectService = ProjectService();
  
  Map<String, dynamic> _dashboardMetrics = {};
  List<ProjectModel> _activeProjects = [];
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
        final metrics = await _firestoreService.getFreelancerDashboardMetrics(currentUser.uid);
        
        // Load active projects
        final activeProjectsStream = _projectService.getFreelancerProjects(currentUser.uid);
        final activeProjectsSnapshot = await activeProjectsStream.first;
        
        setState(() {
          _dashboardMetrics = metrics;
          _activeProjects = activeProjectsSnapshot;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  void _navigateToAllProjects() {
    // Navigate to all projects page - implement this navigation as needed
    // For now, show a dialog with all projects
    _showAllProjectsDialog();
  }

  void _showAllProjectsDialog() {
    showDialog(
      context: context,
      builder: (context) => AllProjectsDialog(projects: _activeProjects),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            
            // Metrics Cards
            _buildMetricsSection(),
            const SizedBox(height: 24),
            
            // Active Projects Section (Full Width)
            _buildActiveProjects(),
            const SizedBox(height: 20),
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
            colors: [AppColors.accentPink, AppColors.accentCyan],
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
              'Welcome back, Freelancer!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your projects and track your progress',
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
        if (constraints.maxWidth < 768) crossAxisCount = 2;
        if (constraints.maxWidth < 480) crossAxisCount = 1;
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildMetricCard(
              'Active Projects',
              _dashboardMetrics['activeProjects']?.toString() ?? '0',
              Icons.work_outline,
              AppColors.accentCyan,
            ),
            _buildMetricCard(
              'Completed',
              _dashboardMetrics['completedProjects']?.toString() ?? '0',
              Icons.check_circle_outline,
              AppColors.successGreen,
            ),
            _buildMetricCard(
              'Total Earnings',
              '\$${(_dashboardMetrics['totalEarnings'] ?? 0.0).toStringAsFixed(0)}',
              Icons.attach_money,
              AppColors.warningYellow,
            ),
            _buildMetricCard(
              'Rating',
              '${(_dashboardMetrics['averageRating'] ?? 0.0).toStringAsFixed(1)}⭐',
              Icons.star,
              AppColors.accentPink,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProjects() {
    // Show only recent 3 projects
    final recentProjects = _activeProjects.take(3).toList();
    
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
                const Expanded(
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
                  onPressed: _navigateToAllProjects,
                  child: const Text('View All', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_activeProjects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No active projects yet. Start applying for projects to see them here!',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentProjects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return ProjectCard(
                    project: recentProjects[index],
                    onTap: () => _showProjectDetail(recentProjects[index]),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showProjectDetail(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => ProjectDetailDialog(
        project: project,
        isFreelancer: true,
      ),
    );
  }
}

// Dialog to show all projects
class AllProjectsDialog extends StatelessWidget {
  final List<ProjectModel> projects;

  const AllProjectsDialog({
    super.key,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minWidth: 300,
          minHeight: 400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'All Active Projects',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Projects List
              Expanded(
                child: projects.isEmpty
                    ? const Center(
                        child: Text(
                          'No active projects found.',
                          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        itemCount: projects.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return ProjectCard(
                            project: projects[index],
                            onTap: () {
                              Navigator.pop(context); // Close dialog first
                              _showProjectDetail(context, projects[index]);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProjectDetail(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => ProjectDetailDialog(
        project: project,
        isFreelancer: true,
      ),
    );
  }
}

// Keep the existing ProjectDetailDialog class as it was
class ProjectDetailDialog extends StatefulWidget {
  final ProjectModel project;
  final bool isFreelancer;

  const ProjectDetailDialog({
    super.key,
    required this.project,
    this.isFreelancer = false,
  });

  @override
  State<ProjectDetailDialog> createState() => _ProjectDetailDialogState();
}

class _ProjectDetailDialogState extends State<ProjectDetailDialog> {
  final TextEditingController _applicationController = TextEditingController();
  final bool _isApplying = false;

  @override
  void dispose() {
    _applicationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minWidth: 300,
          minHeight: 400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.project.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Details
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(widget.project.priority).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.project.priorityDisplayName,
                              style: TextStyle(
                                color: _getPriorityColor(widget.project.priority),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Budget: \$${widget.project.budget.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Client
                      Text(
                        'Client: ${widget.project.clientName}',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Due Date
                      Text(
                        'Due Date: ${widget.project.dueDate.formatDate}',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      
                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.project.description,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Skills
                      const Text(
                        'Required Skills',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.project.skills.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accentCyan.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                color: AppColors.accentCyan,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      // Show progress if this is an active project
                      if (widget.project.progress > 0) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: widget.project.progress / 100,
                            backgroundColor: AppColors.borderColor,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.project.progress}% Complete',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return AppColors.successGreen;
      case Priority.medium:
        return AppColors.warningYellow;
      case Priority.high:
        return AppColors.dangerRed;
      case Priority.urgent:
        return AppColors.dangerRed;
    }
  }
}