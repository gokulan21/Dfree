import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class FreelancerReportsPage extends StatefulWidget {
  const FreelancerReportsPage({super.key});

  @override
  State<FreelancerReportsPage> createState() => _FreelancerReportsPageState();
}

class _FreelancerReportsPageState extends State<FreelancerReportsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  
  Map<String, dynamic> _metrics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final metrics = await _firestoreService.getFreelancerDashboardMetrics(currentUser.uid);
        setState(() {
          _metrics = metrics;
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
            content: Text('Error loading reports: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  // Safe getter methods to prevent null and zero division errors
  int get _totalProjects => (_metrics['totalProjects'] as num?)?.toInt() ?? 0;
  int get _activeProjects => (_metrics['activeProjects'] as num?)?.toInt() ?? 0;
  int get _completedProjects => (_metrics['completedProjects'] as num?)?.toInt() ?? 0;
  double get _totalEarnings => (_metrics['totalEarnings'] as num?)?.toDouble() ?? 0.0;
  double get _averageRating => (_metrics['averageRating'] as num?)?.toDouble() ?? 0.0;
  int get _pendingProjects => _totalProjects - _activeProjects - _completedProjects;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Performance Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Key Metrics
              _buildKeyMetrics(),
              const SizedBox(height: 24),
              
              // Project Status Chart (Full Width)
              _buildProjectStatusChart(),
              const SizedBox(height: 24),
              
              // Performance Overview
              _buildPerformanceOverview(),
              const SizedBox(height: 16), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 768) crossAxisCount = 2;
        if (constraints.maxWidth < 480) crossAxisCount = 1;
        
        double childAspectRatio = 1.2;
        if (constraints.maxWidth < 480) childAspectRatio = 2.0;
        
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
              _totalProjects.toString(),
              Icons.folder_outlined,
              AppColors.accentCyan,
              '${_getProjectGrowth().toStringAsFixed(1)}% from last month',
            ),
            _buildMetricCard(
              'Active Projects',
              _activeProjects.toString(),
              Icons.work_outline,
              AppColors.warningYellow,
              'Currently working on',
            ),
            _buildMetricCard(
              'Total Earnings',
              '\$${_totalEarnings.toStringAsFixed(0)}',
              Icons.attach_money,
              AppColors.successGreen,
              'Lifetime earnings',
            ),
            _buildMetricCard(
              'Avg. Rating',
              _averageRating.toStringAsFixed(1),
              Icons.star,
              AppColors.accentPink,
              'Client satisfaction',
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Live',
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectStatusChart() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Project Status Distribution',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _totalProjects > 0 
              ? SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _getPieChartSections(),
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                )
              : Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const Text(
                    'No projects data available',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    if (_totalProjects == 0) return [];
    
    List<PieChartSectionData> sections = [];
    
    if (_activeProjects > 0) {
      double percentage = (_activeProjects / _totalProjects) * 100;
      sections.add(PieChartSectionData(
        value: percentage,
        color: AppColors.warningYellow,
        title: '${percentage.toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    
    if (_completedProjects > 0) {
      double percentage = (_completedProjects / _totalProjects) * 100;
      sections.add(PieChartSectionData(
        value: percentage,
        color: AppColors.successGreen,
        title: '${percentage.toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    
    if (_pendingProjects > 0) {
      double percentage = (_pendingProjects / _totalProjects) * 100;
      sections.add(PieChartSectionData(
        value: percentage,
        color: AppColors.accentCyan,
        title: '${percentage.toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    
    // If no sections, add a default one
    if (sections.isEmpty) {
      sections.add(PieChartSectionData(
        value: 100,
        color: AppColors.textGrey,
        title: '0%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    
    return sections;
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Active', AppColors.warningYellow, _activeProjects),
        _buildLegendItem('Completed', AppColors.successGreen, _completedProjects),
        _buildLegendItem('Pending', AppColors.accentCyan, _pendingProjects),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '$label ($count)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Always horizontal layout
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    'Success Rate',
                    '${_getSuccessRate().toStringAsFixed(1)}%',
                    AppColors.successGreen,
                    Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceMetric(
                    'Avg. Project Duration',
                    '${_getAvgDuration()} days',
                    AppColors.accentCyan,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceMetric(
                    'Client Retention',
                    '${_getClientRetention().toStringAsFixed(1)}%',
                    AppColors.accentPink,
                    Icons.people,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  double _getProjectGrowth() {
    return 25.0; // Placeholder - implement actual calculation
  }

  double _getSuccessRate() {
    if (_totalProjects == 0) return 0.0;
    return (_completedProjects / _totalProjects) * 100;
  }

  int _getAvgDuration() {
    return 21; // Placeholder - implement actual calculation
  }

  double _getClientRetention() {
    return 85.0; // Placeholder - implement actual calculation
  }
}