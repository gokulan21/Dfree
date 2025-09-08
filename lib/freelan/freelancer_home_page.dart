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
  List<ProjectModel> _availableProjects = [];
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
        
        // Load available projects
        final availableProjectsStream = _projectService.getAvailableProjects();
        final availableProjectsSnapshot = await availableProjectsStream.first;
        
        setState(() {
          _dashboardMetrics = metrics;
          _activeProjects = activeProjectsSnapshot.take(5).toList();
          _availableProjects = availableProjectsSnapshot.take(6).toList();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 32),
            
            // Metrics Cards
            _buildMetricsSection(),
            const SizedBox(height: 32),
            
            // Active Projects and Available Projects
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1024) {
                  return Column(
                    children: [
                      _buildActiveProjects(),
                      const SizedBox(height: 24),
                      _buildAvailableProjects(),
                    ],
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildActiveProjects()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildAvailableProjects()),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return CustomCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
          children: [
            const Text(
              'Welcome back, Freelancer!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find new projects and manage your work efficiently',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to available projects
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Projects'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.accentPink,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProjects() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Projects',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to projects page
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_activeProjects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No active projects. Browse available projects to get started!',
                    style: TextStyle(color: AppColors.textGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeProjects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(
                    project: _activeProjects[index],
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

  Widget _buildAvailableProjects() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Projects',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to browse projects
                  },
                  child: const Text('Browse All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_availableProjects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No projects available at the moment.',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableProjects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(
                    project: _availableProjects[index],
                    onTap: () => _showProjectDetail(_availableProjects[index]),
                    showApplyButton: true,
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
  bool _isApplying = false;

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
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.project.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Details
                    Row(
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
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Budget: \$${widget.project.budget.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.successGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Due Date
                    Text(
                      'Due Date: ${widget.project.dueDate.formatDate}',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.project.description,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Skills
                    const Text(
                      'Required Skills',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                    
                    if (widget.isFreelancer) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Application Message',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _applicationController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Write a compelling message to the client...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Action buttons
            if (widget.isFreelancer) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isApplying ? null : _applyForProject,
                    child: _isApplying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Apply for Project'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _applyForProject() async {
    if (_applicationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write an application message'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    setState(() {
      _isApplying = true;
    });

    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await ProjectService().applyForProject(
        widget.project.id,
        currentUser.uid,
        _applicationController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting application: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
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
