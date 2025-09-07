// reports_page.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/card.dart';
import '../service/firestore_service.dart';

class ReportsPage extends StatefulWidget {
  final Map<String, dynamic>? dashboardMetrics;

  const ReportsPage({
    super.key,
    this.dashboardMetrics,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic> _metrics = {};
  List<FlSpot> _completionTrends = [];
  List<PieChartSectionData> _statusDistribution = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load dashboard metrics
      final metrics = widget.dashboardMetrics ?? await _firestoreService.getDashboardMetrics();
      
      // Load additional analytics data
      final analyticsData = await _firestoreService.getAnalyticsData();
      
      setState(() {
        _metrics = {...metrics, ...analyticsData};
        _completionTrends = _generateCompletionTrends(analyticsData);
        _statusDistribution = _generateStatusDistribution(metrics);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<FlSpot> _generateCompletionTrends(Map<String, dynamic> data) {
    final trends = data['completionTrends'] as List<dynamic>? ?? [];
    return trends.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), (entry.value as num).toDouble());
    }).toList();
  }

  List<PieChartSectionData> _generateStatusDistribution(Map<String, dynamic> metrics) {
    final projectsByStatus = metrics['projectsByStatus'] as Map<String, dynamic>? ?? {};
    
    return [
      PieChartSectionData(
        value: (projectsByStatus['inProgress'] ?? 0).toDouble(),
        color: const Color(0xFF33CFFF),
        title: 'In Progress',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: (projectsByStatus['completed'] ?? 0).toDouble(),
        color: Colors.green,
        title: 'Completed',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: (projectsByStatus['pending'] ?? 0).toDouble(),
        color: Colors.amber,
        title: 'Pending',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: (projectsByStatus['overdue'] ?? 0).toDouble(),
        color: Colors.red,
        title: 'Overdue',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1A3C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33CFFF)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading analytics...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1A3C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAnalyticsData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E1A3C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with responsive font size
              Center(
                child: Text(
                  "Analytics & Reports",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 32 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              
              // Dynamic Metrics Grid
              _buildDynamicMetricsGrid(isTablet),
              
              const SizedBox(height: 32),
              
              // Dynamic Charts Grid
              _buildDynamicChartsGrid(isTablet),
              
              const SizedBox(height: 32),
              
              // Additional Analytics
              _buildAdditionalAnalytics(isTablet),
              
              // Bottom padding to prevent content cutoff
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicMetricsGrid(bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isTablet ? 4 : 2;
        const spacing = 16.0;
        final availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
        final cardWidth = availableWidth / crossAxisCount;
        final cardHeight = cardWidth / 1.5;
        final totalHeight = isTablet ? cardHeight : (cardHeight * 2) + spacing;
        
        return SizedBox(
          height: totalHeight,
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.5,
            children: [
              MetricCard(
                title: "Success Rate",
                value: "${(_metrics['successRate'] ?? 94).toStringAsFixed(0)}%",
              ),
              MetricCard(
                title: "Total Revenue",
                value: "\$${(_metrics['totalRevenue'] ?? 47500).toStringAsFixed(0)}",
              ),
              MetricCard(
                title: "Active Freelancers",
                value: "${_metrics['totalFreelancers'] ?? 0}",
              ),
              MetricCard(
                title: "Hours Saved",
                value: "${_metrics['hoursSaved'] ?? 156}",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDynamicChartsGrid(bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isTablet ? 2 : 1;
        const spacing = 16.0;
        final availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
        final cardWidth = availableWidth / crossAxisCount;
        final cardHeight = cardWidth / 1.2;
        final totalHeight = isTablet ? cardHeight : (cardHeight * 2) + spacing;
        
        return SizedBox(
          height: totalHeight,
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.2,
            children: [
              // Dynamic Line Chart Card
              DashboardCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Project Completion Trends",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _completionTrends.isNotEmpty
                            ? LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: false),
                                  titlesData: FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _completionTrends,
                                      isCurved: true,
                                      color: const Color(0xFF33CFFF),
                                      barWidth: 3,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(0xFF33CFFF).withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'No trend data available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Dynamic Pie Chart Card
              DashboardCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Project Status Distribution",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _statusDistribution.isNotEmpty
                            ? PieChart(
                                PieChartData(
                                  sections: _statusDistribution,
                                  centerSpaceRadius: 30,
                                  sectionsSpace: 2,
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'No status data available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdditionalAnalytics(bool isTablet) {
    return Column(
      children: [
        // Performance Overview
        DashboardCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Performance Overview",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceItem(
                        "Avg. Project Duration",
                        "${_metrics['avgProjectDuration'] ?? 0} days",
                        Icons.schedule,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPerformanceItem(
                        "Client Satisfaction",
                        "${(_metrics['clientSatisfaction'] ?? 0).toStringAsFixed(1)}/5.0",
                        Icons.sentiment_very_satisfied,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceItem(
                        "On-Time Delivery",
                        "${(_metrics['onTimeDelivery'] ?? 0).toStringAsFixed(0)}%",
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPerformanceItem(
                        "Budget Efficiency",
                        "${(_metrics['budgetEfficiency'] ?? 0).toStringAsFixed(0)}%",
                        Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Top Performers
        DashboardCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Top Performers This Month",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildTopPerformers(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF33CFFF), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTopPerformers() {
    final topPerformers = _metrics['topPerformers'] as List<dynamic>? ?? [];
    
    if (topPerformers.isEmpty) {
      return [
        const Center(
          child: Text(
            'No performer data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ];
    }

    return topPerformers.take(5).map((performer) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF33CFFF), Color(0xFFFF1EC0)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  performer['name'][0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    performer['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${performer['completedProjects']} projects completed',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${performer['rating']}/5.0',
              style: const TextStyle(
                color: Color(0xFF33CFFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
