// home_page.dart
// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets/card.dart';

class HomePage extends StatelessWidget {
  final List<Freelancer>? freelancers;
  final String? searchQuery;
  final Function(String)? onSearchChanged;
  final Function(Freelancer)? onFreelancerTap;
  final Map<String, dynamic>? dashboardMetrics;
  final bool isFreelancerView;

  const HomePage({
    super.key,
    this.freelancers,
    this.searchQuery,
    this.onSearchChanged,
    this.onFreelancerTap,
    this.dashboardMetrics,
    this.isFreelancerView = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFreelancerView || freelancers == null) {
      return _buildFreelancerDashboard(context);
    }
    
    return _buildClientDashboard(context);
  }

  Widget _buildFreelancerDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1A3C),
      appBar: AppBar(
        title: const Text('Freelancer Dashboard'),
        backgroundColor: const Color(0xFF262047),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B21A8).withOpacity(0.8),
                    const Color(0xFF1E3A8A).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.work_outline, size: 60, color: Color(0xFF33CFFF)),
                  SizedBox(height: 16),
                  Text(
                    'Freelancer Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Android Version',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Dynamic Stats
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                MetricCard(
                  title: "Active Projects",
                  value: "${dashboardMetrics?['activeProjects'] ?? 0}",
                ),
                MetricCard(
                  title: "Completed",
                  value: "${dashboardMetrics?['completedProjects'] ?? 0}",
                ),
                MetricCard(
                  title: "This Month",
                  value: "${dashboardMetrics?['completedThisMonth'] ?? 0}",
                ),
                MetricCard(
                  title: "Rating",
                  value: "${(dashboardMetrics?['averageRating'] ?? 0.0).toStringAsFixed(1)}",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDashboard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      color: const Color(0xFF1E1A3C),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Text(
                "Freelancer Management Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Dynamic Overview Cards
            _buildDynamicOverviewCards(context, isMobile),
            const SizedBox(height: 24),
            
            // Search and Freelancer List
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Search Freelancers",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF33CFFF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_getFilteredFreelancers().length} found",
                          style: const TextStyle(
                            color: Color(0xFF33CFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search TextField
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search by name, skills, or rating...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF151229),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: onSearchChanged,
                  ),
                  const SizedBox(height: 20),
                  
                  // Dynamic Freelancer Grid
                  _buildDynamicFreelancerGrid(context, isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicOverviewCards(BuildContext context, bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        MetricCard(
          title: "Total Freelancers",
          value: "${dashboardMetrics?['totalFreelancers'] ?? freelancers?.length ?? 0}",
        ),
        MetricCard(
          title: "Active Projects",
          value: "${dashboardMetrics?['activeProjects'] ?? 0}",
        ),
        MetricCard(
          title: "Completed This Month",
          value: "${dashboardMetrics?['completedThisMonth'] ?? 0}",
        ),
        MetricCard(
          title: "Average Rating",
          value: "${(dashboardMetrics?['averageRating'] ?? 0.0).toStringAsFixed(1)}",
        ),
      ],
    );
  }

  Widget _buildDynamicFreelancerGrid(BuildContext context, bool isMobile) {
    final filteredFreelancers = _getFilteredFreelancers();
    
    if (filteredFreelancers.isEmpty) {
      return Container(
        height: 200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No freelancers found",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemCount: filteredFreelancers.length,
      itemBuilder: (context, index) {
        final freelancer = filteredFreelancers[index];
        return GestureDetector(
          onTap: () => onFreelancerTap?.call(freelancer),
          child: FreelancerCard(freelancer: freelancer),
        );
      },
    );
  }

  List<Freelancer> _getFilteredFreelancers() {
    if (freelancers == null || (searchQuery?.isEmpty ?? true)) {
      return freelancers ?? [];
    }
    
    final query = searchQuery!.toLowerCase().trim();
    return freelancers!.where((freelancer) {
      return freelancer.name.toLowerCase().contains(query) ||
             freelancer.role.toLowerCase().contains(query) ||
             freelancer.skills.any((skill) => skill.toLowerCase().contains(query)) ||
             freelancer.rating.toString().contains(query);
    }).toList();
  }
}
