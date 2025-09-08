import 'package:flutter/material.dart';
import '../../services/project_service.dart';
import '../../services/auth_service.dart';
import '../../models/project_model.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/project_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class FreelancerProjectsPage extends StatefulWidget {
  const FreelancerProjectsPage({super.key});

  @override
  State<FreelancerProjectsPage> createState() => _FreelancerProjectsPageState();
}

class _FreelancerProjectsPageState extends State<FreelancerProjectsPage>
    with TickerProviderStateMixin {
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();

  late TabController _tabController;
  List<ProjectModel> _myProjects = [];
  List<ProjectModel> _availableProjects = [];
  bool _isLoadingMyProjects = true;
  bool _isLoadingAvailable = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Load my projects
        _projectService.getFreelancerProjects(currentUser.uid).listen((projects) {
          setState(() {
            _myProjects = projects;
            _isLoadingMyProjects = false;
          });
        });

        // Load available projects
        _projectService.getAvailableProjects().listen((projects) {
          setState(() {
            _availableProjects = projects;
            _isLoadingAvailable = false;
          });
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMyProjects = false;
        _isLoadingAvailable = false;
      });
      if (mounted) {
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

    final status = ProjectStatus.values.firstWhere(
      (s) => s.name == _selectedFilter,
      orElse: () => ProjectStatus.pending,
    );

    return _myProjects.where((project) => project.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'My Projects'),
              Tab(text: 'Available Projects'),
            ],
            labelColor: AppColors.accentCyan,
            unselectedLabelColor: AppColors.textGrey,
            indicator: BoxDecoration(
              color: AppColors.accentCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMyProjectsTab(),
              _buildAvailableProjectsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyProjectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters
          _buildFilters(),
          const SizedBox(height: 24),

          // Project Statistics
          _buildProjectStats(),
          const SizedBox(height: 24),

          // Projects List
          _buildMyProjectsList(),
        ],
      ),
    );
  }

  Widget _buildAvailableProjectsTab() {
    if (_isLoadingAvailable) {
      return const Center(child: LoadingWidget());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Browse Available Projects',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_availableProjects.length} projects available',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Available Projects Grid
          if (_availableProjects.isEmpty)
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No projects available at the moment',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check back later for new opportunities',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                if (constraints.maxWidth < 768) crossAxisCount = 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _availableProjects.length,
                  itemBuilder: (context, index) {
                    return ProjectCard(
                      project: _availableProjects[index],
                      onTap: () => _showProjectDetail(_availableProjects[index]),
                      showApplyButton: true,
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        const Text(
          'Filter by status:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('inProgress', 'In Progress'),
                const SizedBox(width: 8),
                _buildFilterChip('completed', 'Completed'),
                const SizedBox(width: 8),
                _buildFilterChip('pending', 'Pending'),
              ],
            ),
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
      ),
    );
  }

  Widget _buildProjectStats() {
    final totalProjects = _myProjects.length;
    final activeProjects = _myProjects.where((p) => p.status == ProjectStatus.inProgress).length;
    final completedProjects = _myProjects.where((p) => p.status == ProjectStatus.completed).length;
    final pendingProjects = _myProjects.where((p) => p.status == ProjectStatus.pending).length;

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
          childAspectRatio: 2,
          children: [
            _buildStatCard('Total', totalProjects, AppColors.accentCyan),
            _buildStatCard('Active', activeProjects, AppColors.warningYellow),
            _buildStatCard('Completed', completedProjects, AppColors.successGreen),
            _buildStatCard('Pending', pendingProjects, AppColors.textGrey),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
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
      return const Center(child: LoadingWidget());
    }

    final filteredProjects = _filteredMyProjects;

    if (filteredProjects.isEmpty) {
      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == 'all'
                      ? 'No projects yet. Browse available projects to get started!'
                      : 'No $_selectedFilter projects found.',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProjects.length,
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
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
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
