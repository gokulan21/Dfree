// ignore_for_file: deprecated_member_use, sized_box_for_whitespace

import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets/card.dart';

class HomePage extends StatelessWidget {
  final List<Freelancer>? freelancers;
  final String? searchQuery;
  final Function(String)? onSearchChanged;
  final Function(Freelancer)? onFreelancerTap;
  final bool isFreelancerView;

  const HomePage({
    super.key,
    this.freelancers,
    this.searchQuery,
    this.onSearchChanged,
    this.onFreelancerTap,
    this.isFreelancerView = false,
  });

  @override
  Widget build(BuildContext context) {
    // If this is freelancer view or no data provided, show simple dashboard
    if (isFreelancerView || freelancers == null) {
      return _buildFreelancerDashboard(context);
    }
    
    // Otherwise show full client dashboard
    return _buildClientDashboard(context);
  }

  Widget _buildFreelancerDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1A3C),
      appBar: AppBar(
        title: const Text('Freelancer Dashboard'),
        backgroundColor: const Color(0xFF262047),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications feature coming soon!'),
                  backgroundColor: Color(0xFF33CFFF),
                ),
              );
            },
          ),
        ],
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
                  Icon(
                    Icons.work_outline,
                    size: 60,
                    color: Color(0xFF33CFFF),
                  ),
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
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Welcome to your freelancer dashboard! Manage your projects, track your progress, and communicate with clients.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Stats for Freelancer
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: const [
                MetricCard(
                  title: "Active Projects",
                  value: "3",
                ),
                MetricCard(
                  title: "Completed",
                  value: "12",
                ),
                MetricCard(
                  title: "This Month",
                  value: "5",
                ),
                MetricCard(
                  title: "Rating",
                  value: "4.8",
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
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
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('View Projects feature coming soon!'),
                                backgroundColor: Color(0xFF33CFFF),
                              ),
                            );
                          },
                          icon: const Icon(Icons.folder_outlined),
                          label: const Text('Projects'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF33CFFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Messages feature coming soon!'),
                                backgroundColor: Color(0xFFFF1EC0),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message_outlined),
                          label: const Text('Messages'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF1EC0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDashboard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return Container(
      color: const Color(0xFF1E1A3C),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: isMobile ? 80 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with responsive design
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 12 : 16,
                horizontal: isMobile ? 8 : 0,
              ),
              child: Text(
                "Freelancer Management Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 22 : (isTablet ? 26 : 28),
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: isMobile ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            
            // Overview Cards Section
            _buildOverviewCards(context, isMobile, isTablet),
            SizedBox(height: isMobile ? 16 : 24),
            
            // Search Section
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 8),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Mobile counter badge
                  if (isMobile) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF33CFFF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_getFilteredFreelancers().length} freelancers found",
                        style: const TextStyle(
                          color: Color(0xFF33CFFF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Search TextField
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 50,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: isMobile 
                            ? "Search freelancers..." 
                            : "Search by name, skills, or rating...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFF151229),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xFF33CFFF)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isMobile ? 10 : 12,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: onSearchChanged,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Freelancer Grid
                  _buildFreelancerGrid(context, isMobile, isTablet),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            
            // Recent Activity
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Recent Activity",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isMobile)
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "View All",
                            style: TextStyle(
                              color: Color(0xFF33CFFF),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._buildActivityItems(isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, bool isMobile, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;
        double crossAxisSpacing;
        double mainAxisSpacing;
        
        if (isMobile) {
          crossAxisCount = 2;
          childAspectRatio = 1.1;
          crossAxisSpacing = 12;
          mainAxisSpacing = 12;
        } else if (isTablet) {
          crossAxisCount = 4;
          childAspectRatio = 1.2;
          crossAxisSpacing = 16;
          mainAxisSpacing = 16;
        } else {
          final cardWidth = (constraints.maxWidth - 48) / 4;
          final canFitFour = cardWidth >= 120;
          crossAxisCount = canFitFour ? 4 : 2;
          childAspectRatio = 1.2;
          crossAxisSpacing = 16;
          mainAxisSpacing = 16;
        }
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
          children: [
            MetricCard(
              title: "Total Freelancers",
              value: "${freelancers?.length ?? 0}",
            ),
            const MetricCard(
              title: "Active Projects",
              value: "12",
            ),
            const MetricCard(
              title: "Completed This Month",
              value: "8",
            ),
            const MetricCard(
              title: "Average Rating",
              value: "4.8",
            ),
          ],
        );
      },
    );
  }

  Widget _buildFreelancerGrid(BuildContext context, bool isMobile, bool isTablet) {
    final filteredFreelancers = _getFilteredFreelancers();
    
    if (filteredFreelancers.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "No freelancers found",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Try adjusting your search terms",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;
        
        if (isMobile) {
          crossAxisCount = 1;
          childAspectRatio = 2.2;
        } else if (isTablet) {
          crossAxisCount = 2;
          childAspectRatio = 2.0;
        } else {
          crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
          childAspectRatio = 2.2;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isMobile ? 12 : 16,
            mainAxisSpacing: isMobile ? 12 : 16,
            childAspectRatio: childAspectRatio,
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
      },
    );
  }

  List<Widget> _buildActivityItems(bool isMobile) {
    final activities = [
      ActivityData(
        icon: Icons.check_circle,
        color: Colors.green,
        title: 'Project "E-commerce Website" completed by Gokul',
        subtitle: "2 hours ago",
      ),
      ActivityData(
        icon: Icons.person_add,
        color: const Color(0xFF33CFFF),
        title: "New freelancer Sarah joined your workspace",
        subtitle: "1 day ago",
      ),
      ActivityData(
        icon: Icons.schedule,
        color: Colors.amber,
        title: "Mobile App project deadline in 3 days",
        subtitle: "Assigned to Mohana",
      ),
      ActivityData(
        icon: Icons.message,
        color: const Color(0xFFFF1EC0),
        title: "New message from Alex about Dashboard project",
        subtitle: "5 minutes ago",
      ),
    ];

    return activities.map((activity) => _buildActivityItem(
      activity.icon,
      activity.color,
      activity.title,
      activity.subtitle,
      isMobile,
    )).toList();
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

  Widget _buildActivityItem(
    IconData icon, 
    Color color, 
    String title, 
    String subtitle, 
    bool isMobile,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF262047),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon, 
                    color: color, 
                    size: isMobile ? 18 : 20,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 13 : 14,
                          height: 1.3,
                        ),
                        maxLines: isMobile ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: isMobile ? 11 : 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  ActivityData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}
