// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    
    return Scaffold(
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
              
              // Metrics Grid with proper sizing
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = isTablet ? 4 : 2;
                  const spacing = 16.0;
                  final availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
                  final cardWidth = availableWidth / crossAxisCount;
                  final cardHeight = cardWidth / 1.5; // Aspect ratio of 1.5
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
                      children: const [
                        MetricCard(title: "Success Rate", value: "94%"),
                        MetricCard(title: "Total Revenue", value: "\$47,500"),
                        MetricCard(title: "Active Freelancers", value: "18"),
                        MetricCard(title: "Hours Saved", value: "156"),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Charts Grid with proper sizing
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = isTablet ? 2 : 1;
                  const spacing = 16.0;
                  final availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
                  final cardWidth = availableWidth / crossAxisCount;
                  final cardHeight = cardWidth / 1.2; // Aspect ratio of 1.2
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
                        // Line Chart Card
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
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(show: false),
                                      titlesData: FlTitlesData(show: false),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: const [
                                            FlSpot(0, 12),
                                            FlSpot(1, 19),
                                            FlSpot(2, 15),
                                            FlSpot(3, 25),
                                            FlSpot(4, 22),
                                            FlSpot(5, 28),
                                          ],
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Pie Chart Card
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
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: 40,
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
                                          value: 35,
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
                                          value: 15,
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
                                          value: 10,
                                          color: Colors.red,
                                          title: 'Overdue',
                                          radius: 50,
                                          titleStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                      centerSpaceRadius: 30,
                                      sectionsSpace: 2,
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
              ),
              
              // Bottom padding to prevent content cutoff
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}