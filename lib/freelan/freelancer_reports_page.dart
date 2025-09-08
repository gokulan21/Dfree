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
          // Header
          const Text(
            'Performance Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Key Metrics
          _buildKeyMetrics(),
          const SizedBox(height: 32),
          
          // Charts Section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1024) {
                return Column(
                  children: [
                    _buildProjectStatusChart(),
                    const SizedBox(height: 24),
                    _buildEarningsChart(),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildProjectStatusChart()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildEarningsChart()),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),
          
          // Performance Overview
          _buildPerformanceOverview(),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
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
              'Total Projects',
              _metrics['totalProjects']?.toString() ?? '0',
              Icons.folder_outlined,
              AppColors.accentCyan,
              '${_getProjectGrowth()}% from last month',
            ),
            _buildMetricCard(
              'Active Projects',
              _metrics['activeProjects']?.toString() ?? '0',
              Icons.work_outline,
              AppColors.warningYellow,
              'Currently working on',
            ),
            _buildMetricCard(
              'Total Earnings',
              '\$${(_metrics['totalEarnings'] ?? 0.0).toStringAsFixed(0)}',
              Icons.attach_money,
              AppColors.successGreen,
              'Lifetime earnings',
            ),
            _buildMetricCard(
              'Avg. Rating',
              (_metrics['averageRating'] ?? 0.0).toStringAsFixed(1),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Live',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Status Distribution',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _getPieChartSections(),
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
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
    final total = _metrics['totalProjects'] ?? 1;
    final active = _metrics['activeProjects'] ?? 0;
    final completed = _metrics['completedProjects'] ?? 0;
    final pending = total - active - completed;
    
    return [
      PieChartSectionData(
        value: (active / total * 100),
        color: AppColors.warningYellow,
        title: '${(active / total * 100).toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: (completed / total * 100),
        color: AppColors.successGreen,
        title: '${(completed / total * 100).toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      if (pending > 0)
        PieChartSectionData(
          value: (pending / total * 100),
          color: AppColors.accentCyan,
          title: '${(pending / total * 100).toInt()}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];
  }

  Widget _buildChartLegend() {
    return Column(
      children: [
        _buildLegendItem('Active', AppColors.warningYellow, _metrics['activeProjects'] ?? 0),
        _buildLegendItem('Completed', AppColors.successGreen, _metrics['completedProjects'] ?? 0),
        _buildLegendItem('Pending', AppColors.accentCyan, 
          (_metrics['totalProjects'] ?? 0) - (_metrics['activeProjects'] ?? 0) - (_metrics['completedProjects'] ?? 0)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label ($count)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsChart() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Earnings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getEarningsSpots(),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [AppColors.accentCyan, AppColors.accentPink],
                      ),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentCyan.withOpacity(0.3),
                            AppColors.accentPink.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getEarningsSpots() {
    // Mock data - replace with actual earnings data
    return const [
      FlSpot(0, 1000),
      FlSpot(1, 1500),
      FlSpot(2, 1200),
      FlSpot(3, 1800),
      FlSpot(4, 2200),
      FlSpot(5, 2000),
    ];
  }

  Widget _buildPerformanceOverview() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    'Success Rate',
                    '${_getSuccessRate()}%',
                    AppColors.successGreen,
                    Icons.check_circle_outline,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceMetric(
                    'Avg. Project Duration',
                    '${_getAvgDuration()} days',
                    AppColors.accentCyan,
                    Icons.schedule,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceMetric(
                    'Client Retention',
                    '${_getClientRetention()}%',
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
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _getProjectGrowth() {
    return 25.0; // Placeholder
  }

  double _getSuccessRate() {
    final total = _metrics['totalProjects'] ?? 0;
    final completed = _metrics['completedProjects'] ?? 0;
    if (total == 0) return 0.0;
    return (completed / total * 100);
  }

  int _getAvgDuration() {
    return 21; // Placeholder
  }

  double _getClientRetention() {
    return 85.0; // Placeholder
  }
}
