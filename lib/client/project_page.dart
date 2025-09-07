// ignore_for_file: sized_box_for_whitespace, unused_local_variable

import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets/card.dart';

class ProjectsPage extends StatelessWidget {
  final List<Project> projects;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const ProjectsPage({
    super.key,
    required this.projects,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Dynamic breakpoints for different screen sizes
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;
    final isMobile = screenWidth <= 480;
    
    // Dynamic spacing based on screen size
    final basePadding = isMobile ? 12.0 : (isTablet ? 20.0 : 24.0);
    final cardSpacing = isMobile ? 12.0 : 16.0;
    
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(basePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dynamic title with adaptive sizing
                  _buildResponsiveTitle(isTablet, isDesktop, isMobile),
                  SizedBox(height: basePadding * 1.5),
                  
                  // Dynamic metrics grid
                  _buildDynamicMetricsGrid(
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                    isMobile: isMobile,
                    spacing: cardSpacing,
                  ),
                  
                  SizedBox(height: basePadding),
                  
                  // Dynamic filter section
                  _buildDynamicFilterSection(isMobile, basePadding),
                  
                  SizedBox(height: basePadding),
                  
                  // Dynamic projects list
                  _buildDynamicProjectsList(basePadding),
                  
                  // Dynamic bottom padding
                  SizedBox(height: basePadding * 2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveTitle(bool isTablet, bool isDesktop, bool isMobile) {
    double fontSize;
    if (isDesktop) {
      fontSize = 36;
    } else if (isTablet) {
      fontSize = 28;
    } else if (isMobile) {
      fontSize = 20;
    } else {
      fontSize = 24;
    }

    return Center(
      child: Text(
        "Project Management Dashboard",
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: isMobile ? 0.5 : 1.0,
        ),
        textAlign: TextAlign.center,
        maxLines: isMobile ? 2 : 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDynamicMetricsGrid({
    required bool isTablet,
    required bool isDesktop,
    required bool isMobile,
    required double spacing,
  }) {
    // Calculate dynamic grid layout
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 4 : (isMobile ? 1 : 2));
    final childAspectRatio = isMobile ? 3.0 : (isTablet ? 1.8 : 1.5);
    
    // Calculate dynamic metrics from actual project data
    final metrics = _calculateDynamicMetrics();
    
    return LayoutBuilder(
      builder: (context, gridConstraints) {
        final availableWidth = gridConstraints.maxWidth - (spacing * (crossAxisCount - 1));
        final cardWidth = availableWidth / crossAxisCount;
        final cardHeight = cardWidth / childAspectRatio;
        final rows = (metrics.length / crossAxisCount).ceil();
        final totalHeight = (cardHeight * rows) + (spacing * (rows - 1));
        
        return SizedBox(
          height: totalHeight,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: MetricCard(
                  title: metric['title'],
                  value: metric['value'].toString(),
                  onTap: () => onFilterChanged(metric['filter']),
                  isActive: selectedFilter == metric['filter'],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDynamicFilterSection(bool isMobile, double basePadding) {
    final filteredProjects = _getFilteredProjects();
    final filterText = _getFilterDisplayText();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show current filter status
        if (selectedFilter != 'all') ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: basePadding,
              vertical: basePadding / 2,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFF1EC0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFF1EC0).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list,
                  color: const Color(0xFFFF1EC0),
                  size: isMobile ? 16 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Showing $filterText (${filteredProjects.length} projects)',
                  style: TextStyle(
                    color: const Color(0xFFFF1EC0),
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onFilterChanged('all'),
                  child: Icon(
                    Icons.clear,
                    color: const Color(0xFFFF1EC0),
                    size: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: basePadding / 2),
        ],
        
        // Show All Button with dynamic styling
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: () => onFilterChanged('all'),
            icon: Icon(
              selectedFilter == 'all' ? Icons.check_circle : Icons.list,
              size: isMobile ? 16 : 18,
            ),
            label: Text(
              selectedFilter == 'all' ? "Showing All Projects" : "Show All Projects",
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedFilter == 'all' 
                  ? Colors.green 
                  : const Color(0xFFFF1EC0),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 8 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: selectedFilter == 'all' ? 4 : 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicProjectsList(double basePadding) {
    final filteredProjects = _getFilteredProjects();
    
    return DashboardCard(
      child: filteredProjects.isEmpty
          ? _buildEmptyState(basePadding)
          : _buildProjectsList(filteredProjects, basePadding),
    );
  }

  Widget _buildEmptyState(double basePadding) {
    return Padding(
      padding: EdgeInsets.all(basePadding * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No projects found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => onFilterChanged('all'),
            icon: const Icon(Icons.refresh),
            label: const Text("View All Projects"),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF1EC0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(List<Project> filteredProjects, double basePadding) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Projects header with count
        Padding(
          padding: EdgeInsets.all(basePadding),
          child: Row(
            children: [
              Text(
                'Projects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF1EC0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${filteredProjects.length}',
                  style: const TextStyle(
                    color: Color(0xFFFF1EC0),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Project cards with animation
        ...filteredProjects.asMap().entries.map((entry) {
          final index = entry.key;
          final project = entry.value;
          
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeInOut,
            child: ProjectCard(project: project),
          );
        }).toList(),
      ],
    );
  }

  // Dynamic metrics calculation based on actual project data
  List<Map<String, dynamic>> _calculateDynamicMetrics() {
    final activeCount = projects.where((p) => p.status == ProjectStatus.inProgress).length;
    final completedCount = projects.where((p) => p.status == ProjectStatus.completed).length;
    final overdueCount = projects.where((p) => p.status == ProjectStatus.overdue).length;
    final totalCount = projects.length;

    return [
      {
        'title': 'Total Projects',
        'value': totalCount,
        'filter': 'all',
        'color': Colors.blue,
      },
      {
        'title': 'In Progress',
        'value': activeCount,
        'filter': 'inprogress',
        'color': Colors.orange,
      },
      {
        'title': 'Completed',
        'value': completedCount,
        'filter': 'completed',
        'color': Colors.green,
      },
      {
        'title': 'Overdue',
        'value': overdueCount,
        'filter': 'overdue',
        'color': Colors.red,
      },
    ];
  }

  List<Project> _getFilteredProjects() {
    if (selectedFilter == 'all') return projects;
    
    return projects.where((project) {
      switch (selectedFilter) {
        case 'active':
        case 'inprogress':
          return project.status == ProjectStatus.inProgress;
        case 'completed':
          return project.status == ProjectStatus.completed;
        case 'overdue':
          return project.status == ProjectStatus.overdue;
        default:
          return true;
      }
    }).toList();
  }

  String _getFilterDisplayText() {
    switch (selectedFilter) {
      case 'inprogress':
        return 'In Progress Projects';
      case 'completed':
        return 'Completed Projects';
      case 'overdue':
        return 'Overdue Projects';
      case 'active':
        return 'Active Projects';
      default:
        return 'All Projects';
    }
  }

  String _getEmptyStateMessage() {
    switch (selectedFilter) {
      case 'inprogress':
        return 'No projects are currently in progress.';
      case 'completed':
        return 'No projects have been completed yet.';
      case 'overdue':
        return 'Great! No projects are overdue.';
      case 'active':
        return 'No active projects found.';
      default:
        return 'No projects available at the moment.';
    }
  }
}