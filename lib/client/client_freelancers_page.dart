import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/freelancer_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class ClientFreelancersPage extends StatefulWidget {
  const ClientFreelancersPage({super.key});

  @override
  State<ClientFreelancersPage> createState() => _ClientFreelancersPageState();
}

class _ClientFreelancersPageState extends State<ClientFreelancersPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  
  List<UserModel> _freelancers = [];
  List<UserModel> _filteredFreelancers = [];
  List<ProjectModel> _availableProjects = [];
  bool _isLoading = true;
  String _selectedSkillFilter = 'all';
  double _minRating = 0.0;
  double _maxHourlyRate = 1000.0;
  StreamSubscription<List<UserModel>>? _freelancersSubscription;
  StreamSubscription<List<ProjectModel>>? _projectsSubscription;
  String? _error;

  final List<String> _skillFilters = [
    'all', 'Flutter', 'React', 'Node.js', 'Python', 'JavaScript',
    'UI/UX Design', 'Graphic Design', 'Content Writing',
    'Digital Marketing', 'SEO', 'Data Analysis',
  ];

  @override
  void initState() {
    super.initState();
    _loadFreelancers();
    _loadAvailableProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _freelancersSubscription?.cancel();
    _projectsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadFreelancers() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _freelancersSubscription?.cancel();
      
      _freelancersSubscription = _firestoreService.getFreelancers().listen(
        (freelancers) {
          if (mounted) {
            setState(() {
              _freelancers = freelancers;
              _isLoading = false;
              _error = null;
            });
            _applyFilters();
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _error = error.toString();
            });
            _showErrorSnackBar('Error loading freelancers: ${error.toString()}');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        _showErrorSnackBar('Error loading freelancers: ${e.toString()}');
      }
    }
  }

  Future<void> _loadAvailableProjects() async {
    try {
      final currentUserId = _firestoreService.getCurrentUserId();
      if (currentUserId != null) {
        _projectsSubscription = _firestoreService.getAvailableClientProjects(currentUserId).listen(
          (projects) {
            if (mounted) {
              setState(() {
                _availableProjects = projects;
              });
            }
          },
          onError: (error) {
            debugPrint('Error loading available projects: $error');
          },
        );
      }
    } catch (e) {
      debugPrint('Error loading available projects: $e');
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    
    List<UserModel> filtered = List.from(_freelancers);
    
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((freelancer) {
        return freelancer.name.toLowerCase().contains(searchQuery) ||
               (freelancer.bio?.toLowerCase().contains(searchQuery) ?? false) ||
               freelancer.skills.any((skill) => skill.toLowerCase().contains(searchQuery));
      }).toList();
    }
    
    if (_selectedSkillFilter != 'all') {
      filtered = filtered.where((freelancer) {
        return freelancer.skills.contains(_selectedSkillFilter);
      }).toList();
    }
    
    filtered = filtered.where((freelancer) {
      return freelancer.rating >= _minRating && freelancer.hourlyRate <= _maxHourlyRate;
    }).toList();
    
    setState(() {
      _filteredFreelancers = filtered;
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchAndFilters(),
              const SizedBox(height: 24),
              _buildFreelancersGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find Freelancers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_filteredFreelancers.length} freelancers available',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAdvancedFilters,
                  icon: const Icon(Icons.tune),
                  label: const Text('Advanced Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentCyan,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Freelancers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_filteredFreelancers.length} freelancers available',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _showAdvancedFilters,
              icon: const Icon(Icons.tune),
              label: const Text('Advanced Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCyan,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search freelancers by name, skills, or bio...',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                prefixIcon: const Icon(Icons.search, color: AppColors.accentCyan),
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
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _skillFilters.map((skill) {
                  final isSelected = _selectedSkillFilter == skill;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(skill == 'all' ? 'All Skills' : skill),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedSkillFilter = skill;
                          });
                          _applyFilters();
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
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreelancersGrid() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Loading freelancers...'),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredFreelancers.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 1200) crossAxisCount = 2;
        if (constraints.maxWidth < 768) crossAxisCount = 1;
        
        double aspectRatio = 0.85;
        if (constraints.maxWidth < 768) aspectRatio = 1.2;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemCount: _filteredFreelancers.length,
          itemBuilder: (context, index) {
            return FreelancerCard(
              freelancer: _filteredFreelancers[index],
              onTap: () => _showFreelancerDetail(_filteredFreelancers[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.dangerRed,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error loading freelancers',
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFreelancers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCyan,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'No freelancers found',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try adjusting your search criteria or filters',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedSkillFilter = 'all';
                    _minRating = 0.0;
                    _maxHourlyRate = 1000.0;
                  });
                  _applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCyan,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Advanced Filters',
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
                  
                  const Text(
                    'Minimum Rating',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.accentCyan,
                      inactiveTrackColor: AppColors.borderColor,
                      thumbColor: AppColors.accentCyan,
                      overlayColor: AppColors.accentCyan.withOpacity(0.2),
                      valueIndicatorColor: AppColors.accentCyan,
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    child: Slider(
                      value: _minRating,
                      min: 0.0,
                      max: 5.0,
                      divisions: 10,
                      label: _minRating.toStringAsFixed(1),
                      onChanged: (value) {
                        setDialogState(() {
                          _minRating = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Maximum Hourly Rate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.accentCyan,
                      inactiveTrackColor: AppColors.borderColor,
                      thumbColor: AppColors.accentCyan,
                      overlayColor: AppColors.accentCyan.withOpacity(0.2),
                      valueIndicatorColor: AppColors.accentCyan,
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    child: Slider(
                      value: _maxHourlyRate,
                      min: 10.0,
                      max: 1000.0,
                      divisions: 99,
                      label: '\$${_maxHourlyRate.toInt()}',
                      onChanged: (value) {
                        setDialogState(() {
                          _maxHourlyRate = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            _minRating = 0.0;
                            _maxHourlyRate = 1000.0;
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCyan,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFreelancerDetail(UserModel freelancer) {
    showDialog(
      context: context,
      builder: (context) => FreelancerDetailDialog(
        freelancer: freelancer,
        availableProjects: _availableProjects,
        onHireFreelancer: _hireFreelancer,
        onSendMessage: _sendMessage,
      ),
    );
  }

  Future<void> _hireFreelancer(UserModel freelancer, ProjectModel project) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: LoadingWidget(message: 'Assigning freelancer...'),
        ),
      );

      await _firestoreService.assignFreelancerToProject(
        projectId: project.id,
        freelancerId: freelancer.id,
        freelancerName: freelancer.name,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Close detail dialog
      if (mounted) Navigator.pop(context);
      
      _showSuccessSnackBar('${freelancer.name} has been assigned to ${project.title}');
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      _showErrorSnackBar('Failed to assign freelancer: ${e.toString()}');
    }
  }

  Future<void> _sendMessage(UserModel freelancer) async {
    final TextEditingController messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Message ${freelancer.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: messageController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
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
              ),
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
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (messageController.text.trim().isNotEmpty) {
                        try {
                          final currentUserId = _firestoreService.getCurrentUserId();
                          if (currentUserId != null) {
                            await _firestoreService.sendMessageToFreelancer(
                              freelancerId: freelancer.id,
                              clientId: currentUserId,
                              message: messageController.text.trim(),
                            );
                            
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context); // Close freelancer detail dialog
                              _showSuccessSnackBar('Message sent to ${freelancer.name}');
                            }
                          }
                        } catch (e) {
                          _showErrorSnackBar('Failed to send message: ${e.toString()}');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCyan,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced FreelancerDetailDialog with proper implementation
class FreelancerDetailDialog extends StatelessWidget {
  final UserModel freelancer;
  final List<ProjectModel> availableProjects;
  final Function(UserModel, ProjectModel) onHireFreelancer;
  final Function(UserModel) onSendMessage;

  const FreelancerDetailDialog({
    super.key,
    required this.freelancer,
    required this.availableProjects,
    required this.onHireFreelancer,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: _buildContent(),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accentCyan, AppColors.accentPink],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              freelancer.name.isNotEmpty ? freelancer.name[0].toUpperCase() : 'F',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  freelancer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < freelancer.rating.floor()
                          ? Icons.star
                          : (index < freelancer.rating ? Icons.star_half : Icons.star_border),
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${freelancer.rating.toStringAsFixed(1)} (${freelancer.totalProjects} projects)',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          freelancer.bio ?? 'No bio available',
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        
        const Text(
          'Skills',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: freelancer.skills.map((skill) {
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
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hourly Rate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '\$${freelancer.hourlyRate.toStringAsFixed(0)}/hr',
                      style: const TextStyle(
                        color: AppColors.successGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                    'Completed Projects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    freelancer.completedProjects.toString(),
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
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => onSendMessage(freelancer),
                  icon: const Icon(Icons.message),
                  label: const Text('Send Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentCyan,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showProjectSelection(context),
                  icon: const Icon(Icons.work),
                  label: const Text('Hire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPink,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onSendMessage(freelancer),
                icon: const Icon(Icons.message),
                label: const Text('Send Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCyan,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showProjectSelection(context),
                icon: const Icon(Icons.work),
                label: const Text('Hire'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPink,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProjectSelection(BuildContext context) {
    if (availableProjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available projects to assign. Create a new project first.'),
          backgroundColor: AppColors.warningYellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ProjectSelectionDialog(
        projects: availableProjects,
        freelancer: freelancer,
        onProjectSelected: (project) => onHireFreelancer(freelancer, project),
      ),
    );
  }
}

// Enhanced ProjectSelectionDialog
class ProjectSelectionDialog extends StatelessWidget {
  final List<ProjectModel> projects;
  final UserModel freelancer;
  final Function(ProjectModel) onProjectSelected;

  const ProjectSelectionDialog({
    super.key,
    required this.projects,
    required this.freelancer,
    required this.onProjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Select Project for ${freelancer.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${projects.length} available projects',
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: projects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return CustomCard(
                    onTap: () {
                      Navigator.pop(context);
                      onProjectSelected(project);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  project.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(project.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  project.statusDisplayName,
                                  style: TextStyle(
                                    color: _getStatusColor(project.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project.description,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: AppColors.successGreen,
                                size: 16,
                              ),
                              Text(
                                '\$${project.budget.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.successGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.schedule,
                                color: AppColors.textGrey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${project.dueDate.formatDate}',
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (project.skills.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: project.skills.take(3).map((skill) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentCyan.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    skill,
                                    style: const TextStyle(
                                      color: AppColors.accentCyan,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
}
