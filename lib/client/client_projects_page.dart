// ignore_for_file: avoid_print, unused_field, unnecessary_null_comparison, unused_import

import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/firestore_service.dart';
import '../../services/project_service.dart';
import '../../services/auth_service.dart';
import '../../models/project_model.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/project_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/project_detail_dialog.dart';
import '../../utils/constants.dart';

class ClientProjectsPage extends StatefulWidget {
  const ClientProjectsPage({super.key});

  @override
  State<ClientProjectsPage> createState() => _ClientProjectsPageState();
}

class _ClientProjectsPageState extends State<ClientProjectsPage> {
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String? _error;
  StreamSubscription<List<ProjectModel>>? _projectsSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProjects();
  }

  @override
  void dispose() {
    _projectsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthAndLoadProjects() async {
    final currentUser = _authService.currentUser;
    print('Current user: ${currentUser?.uid}');
    print('User email: ${currentUser?.email}');
    
    if (currentUser == null) {
      setState(() {
        _error = 'Please log in to view your projects';
        _isLoading = false;
      });
      return;
    }

    _loadProjects();
  }

  Future<void> _loadProjects() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      print('Loading projects for user: ${currentUser.uid}');

      // Cancel previous subscription
      await _projectsSubscription?.cancel();

      // Listen to the stream with proper error handling
      _projectsSubscription = _projectService.getClientProjects(currentUser.uid).listen(
        (projects) {
          print('Received ${projects.length} projects');
          if (mounted) {
            setState(() {
              _projects = projects;
              _isLoading = false;
              _error = null;
            });
          }
        },
        onError: (error) {
          print('Stream error: $error');
          if (mounted) {
            setState(() {
              _error = _getErrorMessage(error.toString());
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      print('Exception in _loadProjects: $e');
      if (mounted) {
        setState(() {
          _error = _getErrorMessage(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('permission-denied')) {
      return 'Permission denied. Please check your account permissions.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('unavailable')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else {
      return 'An error occurred while loading projects. Please try again.';
    }
  }

  // Fixed filter logic - should work properly with all status types
  List<ProjectModel> get _filteredProjects {
    print('Current filter: $_selectedFilter');
    print('Total projects: ${_projects.length}');
    
    if (_selectedFilter == 'all') {
      print('Showing all projects: ${_projects.length}');
      return _projects;
    }
    
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
      default:
        print('Unknown filter: $_selectedFilter, showing all projects');
        return _projects;
    }
    
    if (filterStatus == null) {
      return _projects;
    }
    
    final filtered = _projects.where((project) => project.status == filterStatus).toList();
    print('Filtered projects for ${filterStatus.name}: ${filtered.length}');
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: const Text(
          'My Projects',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showCreateProjectDialog,
            tooltip: 'Create Project',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProjects,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(
          message: 'Loading projects...',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.dangerRed,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error loading projects',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _loadProjects,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCyan,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.signOut();
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter section
            const Text(
              'Filter by status:',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 24),
            
            // Project Statistics - Only show when "All" is selected
            if (_selectedFilter == 'all') ...[
              _buildProjectStats(),
              const SizedBox(height: 24),
            ],
            
            // Projects List
            _buildProjectsList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filter;
          });
          print('Filter changed to: $filter');
          print('Filtered projects count: ${_filteredProjects.length}');
        }
      },
      selectedColor: AppColors.accentCyan.withOpacity(0.3),
      checkmarkColor: AppColors.accentCyan,
      backgroundColor: AppColors.cardColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accentCyan : AppColors.textGrey,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.accentCyan : AppColors.borderColor,
      ),
    );
  }

  Widget _buildProjectStats() {
    final totalProjects = _projects.length;
    final activeProjects = _projects.where((p) => p.status == ProjectStatus.inProgress).length;
    final completedProjects = _projects.where((p) => p.status == ProjectStatus.completed).length;
    final pendingProjects = _projects.where((p) => p.status == ProjectStatus.pending).length;
    final cancelledProjects = _projects.where((p) => p.status == ProjectStatus.cancelled).length;
    final onHoldProjects = _projects.where((p) => p.status == ProjectStatus.onHold).length;

    // Fixed: Use Column with Wraps instead of GridView to avoid overflow
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Total', totalProjects, AppColors.accentCyan)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('In Progress', activeProjects, AppColors.warningYellow)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Completed', completedProjects, AppColors.successGreen)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Pending', pendingProjects, AppColors.textGrey)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Cancelled', cancelledProjects, AppColors.dangerRed)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('On Hold', onHoldProjects, Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return CustomCard(
      child: Container(
        height: 80, // Fixed height to prevent overflow
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    final filteredProjects = _filteredProjects;
    
    if (filteredProjects.isEmpty) {
      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == 'all' 
                      ? 'No projects found.'
                      : 'No ${_getFilterDisplayName(_selectedFilter).toLowerCase()} projects found.',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_selectedFilter != 'all') ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'all';
                      });
                    },
                    child: const Text(
                      'Show all projects',
                      style: TextStyle(
                        color: AppColors.accentCyan,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: _showCreateProjectDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPink,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

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
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'pending':
        return 'Pending';
      case 'inProgress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'onHold':
        return 'On Hold';
      default:
        return filter;
    }
  }

  void _showCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateProjectDialog(),
    ).then((_) {
      _loadProjects();
    });
  }

  void _showProjectDetail(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => ProjectDetailDialog(
        project: project,
        isFreelancer: false,
        onProjectUpdated: _loadProjects,
      ),
    );
  }
}

// Create Project Dialog
class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  Priority _selectedPriority = Priority.medium;
  final List<String> _selectedSkills = [];
  bool _isLoading = false;
  DateTime _startDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  final List<String> _availableSkills = [
    'Flutter', 'React', 'Node.js', 'Python', 'JavaScript',
    'UI/UX Design', 'Graphic Design', 'Content Writing',
    'Digital Marketing', 'SEO', 'Data Analysis',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
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
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Project',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Project Title',
                          hintText: 'Enter project title',
                          labelStyle: const TextStyle(color: AppColors.textGrey),
                          hintStyle: const TextStyle(color: AppColors.textGrey),
                          filled: true,
                          fillColor: AppColors.bgSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.accentCyan),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a project title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe your project requirements',
                          labelStyle: const TextStyle(color: AppColors.textGrey),
                          hintStyle: const TextStyle(color: AppColors.textGrey),
                          filled: true,
                          fillColor: AppColors.bgSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.accentCyan),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Budget
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Budget (\$)',
                          hintText: 'Enter project budget',
                          prefixText: '\$ ',
                          labelStyle: const TextStyle(color: AppColors.textGrey),
                          hintStyle: const TextStyle(color: AppColors.textGrey),
                          filled: true,
                          fillColor: AppColors.bgSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.accentCyan),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a budget';
                          }
                          final budget = double.tryParse(value);
                          if (budget == null || budget <= 0) {
                            return 'Please enter a valid budget';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Start Date and Due Date
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Date',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectStartDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgSecondary,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.borderColor),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          color: AppColors.textGrey,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _formatDate(_startDate),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Due Date',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDueDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgSecondary,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.borderColor),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          color: AppColors.textGrey,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _formatDate(_dueDate),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Priority
                      DropdownButtonFormField<Priority>(
                        value: _selectedPriority,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: AppColors.cardColor,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          labelStyle: const TextStyle(color: AppColors.textGrey),
                          filled: true,
                          fillColor: AppColors.bgSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.accentCyan),
                          ),
                        ),
                        items: Priority.values.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(_getPriorityDisplayName(priority)),
                          );
                        }).toList(),
                        onChanged: (priority) {
                          if (priority != null) {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Skills
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Required Skills',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableSkills.map((skill) {
                          final isSelected = _selectedSkills.contains(skill);
                          return FilterChip(
                            label: Text(skill),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSkills.add(skill);
                                } else {
                                  _selectedSkills.remove(skill);
                                }
                              });
                            },
                            selectedColor: AppColors.accentCyan.withOpacity(0.3),
                            checkmarkColor: AppColors.accentCyan,
                            backgroundColor: AppColors.bgSecondary,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.accentCyan : AppColors.textGrey,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.accentCyan : AppColors.borderColor,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPink,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Project'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentCyan,
              onPrimary: Colors.white,
              surface: AppColors.cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_dueDate.isBefore(_startDate)) {
          _dueDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentCyan,
              onPrimary: Colors.white,
              surface: AppColors.cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  String _getPriorityDisplayName(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedSkills.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one required skill'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
      return;
    }

    if (_dueDate.isBefore(_startDate)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Due date must be after start date'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) throw Exception('User not authenticated');
      
      final userData = await FirestoreService().getUser(currentUser.uid);
      if (userData == null) throw Exception('User data not found');

      final project = ProjectModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        clientId: currentUser.uid,
        clientName: userData.name,
        status: ProjectStatus.pending,
        priority: _selectedPriority,
        budget: double.parse(_budgetController.text.trim()),
        startDate: _startDate,
        dueDate: _dueDate,
        skills: _selectedSkills,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ProjectService().createProject(project);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project created successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating project: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}