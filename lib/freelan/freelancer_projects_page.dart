// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/project_service.dart';
import '../../services/auth_service.dart';
import '../../models/project_model.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/project_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/project_detail_dialog.dart';
import '../../utils/constants.dart';

class FreelancerProjectsPage extends StatefulWidget {
  const FreelancerProjectsPage({super.key});

  @override
  State<FreelancerProjectsPage> createState() => _FreelancerProjectsPageState();
}

class _FreelancerProjectsPageState extends State<FreelancerProjectsPage> {
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();

  List<ProjectModel> _myProjects = [];
  bool _isLoadingMyProjects = true;
  String _selectedFilter = 'all';
  StreamSubscription<List<ProjectModel>>? _projectsSubscription;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _projectsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Cancel previous subscription if exists
        _projectsSubscription?.cancel();
        
        // Listen to projects stream
        _projectsSubscription = _projectService.getFreelancerProjects(currentUser.uid).listen(
          (projects) {
            if (mounted) {
              setState(() {
                _myProjects = projects;
                _isLoadingMyProjects = false;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _isLoadingMyProjects = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading projects: ${error.toString()}'),
                  backgroundColor: AppColors.dangerRed,
                ),
              );
            }
          },
        );

        // Set timeout to prevent infinite loading
        Timer(const Duration(seconds: 10), () {
          if (mounted && _isLoadingMyProjects) {
            setState(() {
              _isLoadingMyProjects = false;
            });
          }
        });
      } else {
        // No user logged in
        if (mounted) {
          setState(() {
            _isLoadingMyProjects = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMyProjects = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading projects: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  List<ProjectModel> get _filteredMyProjects {
    if (_selectedFilter == 'all') return _myProjects;

    ProjectStatus? filterStatus;
    switch (_selectedFilter) {
      case 'pending':
        filterStatus = ProjectStatus.pending;
        break;
      case 'inProgress':
        filterStatus = ProjectStatus.inProgress;
        break;
      case 'completed':
        filterStatus = ProjectStatus.completed;
        break;
      case 'cancelled':
        filterStatus = ProjectStatus.cancelled;
        break;
      case 'onHold':
        filterStatus = ProjectStatus.onHold;
        break;
    }

    if (filterStatus != null) {
      return _myProjects.where((project) => project.status == filterStatus).toList();
    }

    return _myProjects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: _buildMyProjectsContent(),
      ),
    );
  }

  Widget _buildMyProjectsContent() {
    return RefreshIndicator(
      onRefresh: _loadProjects,
      color: AppColors.accentCyan,
      backgroundColor: AppColors.cardColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'My Projects',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Filters
            _buildFilters(),
            const SizedBox(height: 16),

            // Project Statistics
            if (!_isLoadingMyProjects) ...[
              _buildProjectStats(),
              const SizedBox(height: 16),
            ],

            // Projects List
            _buildMyProjectsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by status:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', 'All'),
              const SizedBox(width: 8),
              _buildFilterChip('pending', 'Pending'),
              const SizedBox(width: 8),
              _buildFilterChip('inProgress', 'In Progress'),
              const SizedBox(width: 8),
              _buildFilterChip('completed', 'Completed'),
              const SizedBox(width: 8),
              _buildFilterChip('cancelled', 'Cancelled'),
              const SizedBox(width: 8),
              _buildFilterChip('onHold', 'On Hold'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      selectedColor: AppColors.accentCyan.withOpacity(0.3),
      checkmarkColor: AppColors.accentCyan,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accentCyan : AppColors.textGrey,
        fontSize: 12,
      ),
      backgroundColor: AppColors.cardColor,
      side: BorderSide(
        color: isSelected ? AppColors.accentCyan : AppColors.borderColor,
      ),
    );
  }

  Widget _buildProjectStats() {
    // Use filtered projects based on selected filter
    final filteredProjects = _filteredMyProjects;
    
    // Calculate stats based on filtered projects
    final totalProjects = filteredProjects.length;
    final activeProjects = filteredProjects.where((p) => p.status == ProjectStatus.inProgress).length;
    final completedProjects = filteredProjects.where((p) => p.status == ProjectStatus.completed).length;
    final pendingProjects = filteredProjects.where((p) => p.status == ProjectStatus.pending).length;
    final cancelledProjects = filteredProjects.where((p) => p.status == ProjectStatus.cancelled).length;
    final onHoldProjects = filteredProjects.where((p) => p.status == ProjectStatus.onHold).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) crossAxisCount = 4;
        if (constraints.maxWidth < 400) crossAxisCount = 1;

        // Show different stats based on selected filter
        List<Widget> statCards = [];
        
        if (_selectedFilter == 'all') {
          // Show all stats when "All" is selected
          statCards = [
            _buildStatCard('Total', totalProjects, AppColors.accentCyan),
            _buildStatCard('Active', activeProjects, AppColors.warningYellow),
            _buildStatCard('Completed', completedProjects, AppColors.successGreen),
            _buildStatCard('Pending', pendingProjects, AppColors.textGrey),
          ];
        } else {
          // Show only the total count for specific filters
          String filterLabel = '';
          switch (_selectedFilter) {
            case 'pending':
              filterLabel = 'Pending';
              break;
            case 'inProgress':
              filterLabel = 'In Progress';
              break;
            case 'completed':
              filterLabel = 'Completed';
              break;
            case 'cancelled':
              filterLabel = 'Cancelled';
              break;
            case 'onHold':
              filterLabel = 'On Hold';
              break;
          }
          
          statCards = [
            _buildStatCard(filterLabel, totalProjects, AppColors.accentCyan),
          ];
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: statCards,
        );
      },
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11,
                      ),
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

  Widget _buildMyProjectsList() {
    if (_isLoadingMyProjects) {
      return CustomCard(
        child: Container(
          padding: const EdgeInsets.all(48.0),
          child: const Center(
            child: LoadingWidget(message: "Loading your projects..."),
          ),
        ),
      );
    }

    final filteredProjects = _filteredMyProjects;

    if (filteredProjects.isEmpty) {
      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  _getEmptyStateMessage(),
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_selectedFilter != 'all') ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'all';
                      });
                    },
                    child: const Text(
                      'Show all projects',
                      style: TextStyle(color: AppColors.accentCyan),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProjects.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return ProjectCard(
                project: filteredProjects[index],
                onTap: () => _showProjectDetail(filteredProjects[index]),
              );
            },
          );
        } else {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: filteredProjects.length,
            itemBuilder: (context, index) {
              return ProjectCard(
                project: filteredProjects[index],
                onTap: () => _showProjectDetail(filteredProjects[index]),
              );
            },
          );
        }
      },
    );
  }

  String _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case 'all':
        return 'No projects yet. Start by applying to available projects!';
      case 'pending':
        return 'No pending projects found.';
      case 'inProgress':
        return 'No projects in progress.';
      case 'completed':
        return 'No completed projects yet.';
      case 'cancelled':
        return 'No cancelled projects.';
      case 'onHold':
        return 'No projects on hold.';
      default:
        return 'No projects found for the selected filter.';
    }
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