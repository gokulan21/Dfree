// ignore_for_file: sized_box_for_whitespace

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
    final isTablet = screenWidth > 768;
    
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with responsive font size
                  Center(
                    child: Text(
                      "Project Management Dashboard",
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
                    builder: (context, gridConstraints) {
                      final crossAxisCount = isTablet ? 4 : 2;
                      const spacing = 16.0;
                      final availableWidth = gridConstraints.maxWidth - (spacing * (crossAxisCount - 1));
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
                          children: [
                            MetricCard(
                              title: "Active Projects",
                              value: "12",
                              onTap: () => onFilterChanged('active'),
                              isActive: selectedFilter == 'active',
                            ),
                            MetricCard(
                              title: "In Progress",
                              value: "8",
                              onTap: () => onFilterChanged('inprogress'),
                              isActive: selectedFilter == 'inprogress',
                            ),
                            MetricCard(
                              title: "Completed",
                              value: "15",
                              onTap: () => onFilterChanged('completed'),
                              isActive: selectedFilter == 'completed',
                            ),
                            MetricCard(
                              title: "Overdue",
                              value: "2",
                              onTap: () => onFilterChanged('overdue'),
                              isActive: selectedFilter == 'overdue',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Show All Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () => onFilterChanged('all'),
                      icon: const Icon(Icons.list),
                      label: const Text("Show All Projects"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1EC0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Projects List
                  DashboardCard(
                    child: _getFilteredProjects().isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                "No projects found for the selected filter.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _getFilteredProjects()
                                .map((project) => ProjectCard(project: project))
                                .toList(),
                          ),
                  ),
                  
                  // Bottom padding to prevent content from being cut off
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
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


}