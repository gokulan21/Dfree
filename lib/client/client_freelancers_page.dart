import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
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
  bool _isLoading = true;
  String _selectedSkillFilter = 'all';
  double _minRating = 0.0;
  double _maxHourlyRate = 1000.0;
  StreamSubscription<List<UserModel>>? _freelancersSubscription;
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _freelancersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadFreelancers() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cancel previous subscription
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading freelancers: ${error.toString()}'),
                backgroundColor: AppColors.dangerRed,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading freelancers: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    
    List<UserModel> filtered = List.from(_freelancers);
    
    // Search filter
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((freelancer) {
        return freelancer.name.toLowerCase().contains(searchQuery) ||
               (freelancer.bio?.toLowerCase().contains(searchQuery) ?? false) ||
               freelancer.skills.any((skill) => skill.toLowerCase().contains(searchQuery));
      }).toList();
    }
    
    // Skill filter
    if (_selectedSkillFilter != 'all') {
      filtered = filtered.where((freelancer) {
        return freelancer.skills.contains(_selectedSkillFilter);
      }).toList();
    }
    
    // Rating filter
    filtered = filtered.where((freelancer) {
      return freelancer.rating >= _minRating;
    }).toList();
    
    // Hourly rate filter
    filtered = filtered.where((freelancer) {
      return freelancer.hourlyRate <= _maxHourlyRate;
    }).toList();
    
    setState(() {
      _filteredFreelancers = filtered;
    });
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
              // Header
              _buildHeader(),
              const SizedBox(height: 24),
              
              // Search and Filters
              _buildSearchAndFilters(),
              const SizedBox(height: 24),
              
              // Freelancers Grid
              _buildFreelancersGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
  }

  Widget _buildSearchAndFilters() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search bar
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
            
            // Skill filters
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
        child: LoadingWidget(
          message: 'Loading freelancers...',
        ),
      );
    }

    if (_error != null) {
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

    if (_filteredFreelancers.isEmpty) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 1200) crossAxisCount = 2;
        if (constraints.maxWidth < 768) crossAxisCount = 1;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
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
                  
                  // Rating filter
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
                  
                  // Hourly rate filter
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
                  
                  // Action buttons
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
      builder: (context) => FreelancerDetailDialog(freelancer: freelancer),
    );
  }
}

class FreelancerDetailDialog extends StatelessWidget {
  final UserModel freelancer;

  const FreelancerDetailDialog({super.key, required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                      Text(
                        freelancer.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                          Text(
                            '${freelancer.rating.toStringAsFixed(1)} (${freelancer.totalProjects} projects)',
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
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
            ),
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bio
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
                    
                    // Skills
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
                    
                    // Stats
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
                              Text(
                                '\$${freelancer.hourlyRate.toStringAsFixed(0)}/hr',
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
                ),
              ),
            ),
            
            // Action buttons
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to messaging or implement send message functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Messaging feature coming soon!'),
                          backgroundColor: AppColors.accentCyan,
                        ),
                      );
                    },
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
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to hire freelancer or implement hire functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hire feature coming soon!'),
                          backgroundColor: AppColors.accentPink,
                        ),
                      );
                    },
                    icon: const Icon(Icons.work),
                    label: const Text('Hire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPink,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}