import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/project_service.dart';
import '../../services/auth_service.dart';
import '../../models/project_model.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/project_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class ClientProjectsPage extends StatefulWidget {
  const ClientProjectsPage({super.key});

  @override
  State<ClientProjectsPage> createState() => _ClientProjectsPageState();
}

class _ClientProjectsPageState extends State<ClientProjectsPage> {
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  
  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        _projectService.getClientProjects(currentUser.uid).listen((projects) {
          if (mounted) {
            setState(() {
              _projects = projects;
              _isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
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

  List<ProjectModel> get _filteredProjects {
    if (_selectedFilter == 'all') return _projects;
    
    final status = ProjectStatus.values.firstWhere(
      (s) => s.name == _selectedFilter,
      orElse: () => ProjectStatus.pending,
    );
    
    return _projects.where((project) => project.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          _buildHeader(),
          const SizedBox(height: 24),
          
          // Project Statistics
          _buildProjectStats(),
          const SizedBox(height: 24),
          
          // Projects List
          _buildProjectsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Projects',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            _buildFilterChip('all', 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('pending', 'Pending'),
            const SizedBox(width: 8),
            _buildFilterChip('inProgress', 'Active'),
            const SizedBox(width: 8),
            _buildFilterChip('completed', 'Completed'),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _showCreateProjectDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: Colors.white,
              ),
            ),
          ],
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
    final totalProjects = _projects.length;
    final activeProjects = _projects.where((p) => p.status == ProjectStatus.inProgress).length;
    final completedProjects = _projects.where((p) => p.status == ProjectStatus.completed).length;
    final pendingProjects = _projects.where((p) => p.status == ProjectStatus.pending).length;

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

  Widget _buildProjectsList() {
    final filteredProjects = _filteredProjects;
    
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
                      ? 'No projects yet. Create your first project!'
                      : 'No $_selectedFilter projects found.',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                  ),
                ),
                if (_selectedFilter == 'all') ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showCreateProjectDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Project'),
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

  void _showCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateProjectDialog(),
    );
  }

  void _showProjectDetail(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => ProjectDetailDialog(project: project),
    );
  }
}

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
                        decoration: const InputDecoration(
                          labelText: 'Project Title',
                          hintText: 'Enter project title',
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
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe your project requirements',
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
                        decoration: const InputDecoration(
                          labelText: 'Budget (\$)',
                          hintText: 'Enter project budget',
                          prefixText: '\$ ',
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
                      
                      // Priority
                      DropdownButtonFormField<Priority>(
                        value: _selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
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
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.accentCyan : AppColors.textGrey,
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
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createProject,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
        startDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
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

class ProjectDetailDialog extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailDialog({super.key, required this.project});

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
                    project.title,
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
                    // Status and Priority
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(project.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusDisplayName(project.status),
                            style: TextStyle(
                              color: _getStatusColor(project.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(project.priority).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getPriorityDisplayName(project.priority),
                            style: TextStyle(
                              color: _getPriorityColor(project.priority),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
                      project.description,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Project Details
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Budget',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${project.budget.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.successGreen,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Progress',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${project.progress}%',
                                style: const TextStyle(
                                  color: AppColors.accentCyan,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      children: project.skills.map((skill) {
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
                  ],
                ),
              ),
            ),
            
            // Action buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (project.freelancerId == null) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      // Show freelancer selection
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Assign Freelancer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                ElevatedButton.icon(
                  onPressed: () {
                    // Edit project
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDisplayName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return 'Pending';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
      case ProjectStatus.onHold:
        return 'On Hold';
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

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return AppColors.warningYellow;
      case ProjectStatus.inProgress:
        return AppColors.accentCyan;
      case ProjectStatus.completed:
        return AppColors.successGreen;
      case ProjectStatus.cancelled:
        return AppColors.dangerRed;
      case ProjectStatus.onHold:
        return AppColors.textGrey;
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