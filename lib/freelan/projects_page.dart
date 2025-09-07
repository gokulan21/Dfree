// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../widgets/data_models.dart';

class ProjectsPage extends StatefulWidget {
  final Map<String, ProjectData> projectData;
  final Map<String, ClientData> clientData;
  final bool showCategorizedView;
  final Function(bool) onViewToggle;
  final Function(String, ProjectData) onProjectUpdate; // Add this callback

  const ProjectsPage({
    Key? key,
    required this.projectData,
    required this.clientData,
    required this.showCategorizedView,
    required this.onViewToggle,
    required this.onProjectUpdate, // Add this parameter
  }) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header with responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 768) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'All Projects',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHeaderButtons(context, true),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Projects',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: textWhite,
                        ),
                      ),
                      _buildHeaderButtons(context, false),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            if (widget.showCategorizedView) 
              _buildCategorizedProjects(context) 
            else 
              _buildAllProjectsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButtons(BuildContext context, bool isVertical) {
    final buttons = [
      ElevatedButton.icon(
        onPressed: () => widget.onViewToggle(true),
        icon: const Icon(Icons.grid_view, size: 18),
        label: const Text('Categorized'),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.showCategorizedView ? accentCyan : Colors.grey[700],
          foregroundColor: textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      ElevatedButton.icon(
        onPressed: () => widget.onViewToggle(false),
        icon: const Icon(Icons.list, size: 18),
        label: const Text('All Projects'),
        style: ElevatedButton.styleFrom(
          backgroundColor: !widget.showCategorizedView ? accentCyan : Colors.grey[700],
          foregroundColor: textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    ];

    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((button) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: button,
        )).toList(),
      );
    } else {
      return Wrap(
        spacing: 8,
        children: buttons,
      );
    }
  }

  Widget _buildCategorizedProjects(BuildContext context) {
    final projectsByStatus = <ProjectStatus, List<ProjectData>>{};
    
    for (final project in widget.projectData.values) {
      projectsByStatus.putIfAbsent(project.status, () => []).add(project);
    }

    return Column(
      children: [
        // Statistics with responsive grid
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 4;
            if (constraints.maxWidth < 600) crossAxisCount = 2;
            if (constraints.maxWidth < 400) crossAxisCount = 1;
            
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: crossAxisCount == 1 ? 3 : 1.8,
              children: [
                _buildProjectStatusCard('To Do', projectsByStatus[ProjectStatus.todo]?.length ?? 0, Colors.blue),
                _buildProjectStatusCard('In Progress', projectsByStatus[ProjectStatus.inProgress]?.length ?? 0, Colors.yellow),
                _buildProjectStatusCard('Overdue', projectsByStatus[ProjectStatus.overdue]?.length ?? 0, Colors.red),
                _buildProjectStatusCard('Completed', projectsByStatus[ProjectStatus.completed]?.length ?? 0, Colors.green),
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        // Projects by status
        ...ProjectStatus.values.map((status) {
          final projects = projectsByStatus[status] ?? [];
          if (projects.isEmpty) return const SizedBox.shrink();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${getStatusTitle(status)} (${projects.length})',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: getStatusColor(status),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 3;
                  if (constraints.maxWidth < 1024) crossAxisCount = 2;
                  if (constraints.maxWidth < 768) crossAxisCount = 1;
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: crossAxisCount == 1 ? 1.4 : 1.0,
                    ),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectCard(context, projects[index]);
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProjectStatusCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [bgSecondary, Color(0xFF252147)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectData project) {
    return InkWell(
      onTap: () => _showProjectDetail(context, project.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentCyan.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textWhite,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: getPriorityColor(project.priority).withOpacity(0.2),
                    border: Border.all(color: getPriorityColor(project.priority)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    getPriorityText(project.priority),
                    style: TextStyle(
                      fontSize: 9,
                      color: getPriorityColor(project.priority),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              project.client,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: project.progress / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: project.status == ProjectStatus.completed 
                        ? const LinearGradient(colors: [Colors.green, Colors.green])
                        : const LinearGradient(colors: [accentCyan, accentPink]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${project.progress}% Complete',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[400],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.status == ProjectStatus.completed 
                        ? 'Completed: ${project.completedDate}' 
                        : 'Due: ${project.dueDate}',
                    style: TextStyle(
                      fontSize: 9,
                      color: project.status == ProjectStatus.overdue ? Colors.red : Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: getStatusColor(project.status).withOpacity(0.2),
                    border: Border.all(color: getStatusColor(project.status)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    getStatusText(project.status),
                    style: TextStyle(
                      fontSize: 9,
                      color: getStatusColor(project.status),
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

  Widget _buildAllProjectsList(BuildContext context) {
    return Column(
      children: widget.projectData.values.map((project) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentCyan.withOpacity(0.2)),
          ),
          child: InkWell(
            onTap: () => _showProjectDetail(context, project.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textWhite,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: getPriorityColor(project.priority).withOpacity(0.2),
                        border: Border.all(color: getPriorityColor(project.priority)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        getPriorityText(project.priority),
                        style: TextStyle(
                          fontSize: 12,
                          color: getPriorityColor(project.priority),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProjectInfo(project),
                          const SizedBox(height: 12),
                          _buildProjectActions(project),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(child: _buildProjectInfo(project)),
                          const SizedBox(width: 16),
                          _buildProjectActions(project),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  project.description,
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: project.progress / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: project.status == ProjectStatus.completed 
                                  ? const LinearGradient(colors: [Colors.green, Colors.green])
                                  : const LinearGradient(colors: [accentCyan, accentPink]),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${project.progress}%',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectInfo(ProjectData project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Client:', project.client),
        const SizedBox(height: 4),
        _buildInfoRow(
          project.status == ProjectStatus.completed ? 'Completed:' : 'Due:',
          project.completedDate ?? project.dueDate,
        ),
        const SizedBox(height: 4),
        _buildInfoRow('Budget:', project.budget),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: textWhite, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectActions(ProjectData project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: getStatusColor(project.status).withOpacity(0.2),
            border: Border.all(color: getStatusColor(project.status)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            getStatusText(project.status),
            style: TextStyle(
              fontSize: 12,
              color: getStatusColor(project.status),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Time Spent: ${project.timeSpent}',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  void _showProjectDetail(BuildContext context, String projectId) {
    final project = widget.projectData[projectId];
    if (project == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: bgPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 900,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[700]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textWhite,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[400]),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          return Column(
                            children: [
                              _buildProjectOverview(project),
                              const SizedBox(height: 24),
                              _buildTaskBreakdown(context, project),
                            ],
                          );
                        } else {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildProjectOverview(project)),
                              const SizedBox(width: 24),
                              Expanded(child: _buildTaskBreakdown(context, project)),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectOverview(ProjectData project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 16),
        ...[
          _buildOverviewRow('Client:', project.client),
          _buildOverviewRow('Status:', getStatusText(project.status)),
          _buildOverviewRow('Priority:', getPriorityText(project.priority)),
          _buildOverviewRow(
            project.status == ProjectStatus.completed ? 'Completed:' : 'Due Date:',
            project.completedDate ?? project.dueDate,
          ),
          _buildOverviewRow('Budget:', project.budget),
          _buildOverviewRow('Time Spent:', project.timeSpent),
        ],
        const SizedBox(height: 24),
        const Text(
          'Progress',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: project.progress / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: project.status == ProjectStatus.completed 
                    ? const LinearGradient(colors: [Colors.green, Colors.green])
                    : const LinearGradient(colors: [accentCyan, accentPink]),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${project.progress}% Complete',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Description',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          project.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[300],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Notes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          project.notes,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: textWhite, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskBreakdown(BuildContext context, ProjectData project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 16),
        ...project.tasks.map((task) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: getTaskStatusColor(task.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.name,
                    style: TextStyle(
                      color: task.status == TaskStatus.done ? Colors.grey[500] : textWhite,
                      decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: getTaskStatusColor(task.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    getTaskStatusText(task.status),
                    style: TextStyle(
                      fontSize: 9,
                      color: getTaskStatusColor(task.status),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: constraints.maxWidth < 300 ? 1 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: constraints.maxWidth < 300 ? 6 : 3.5,
              children: [
                _buildQuickActionButton(
                  'Edit Project', 
                  Icons.edit, 
                  accentPink,
                  () => _showEditProjectDialog(context, project),
                ),
                _buildQuickActionButton('Message Client', Icons.message, Colors.grey[700]!, () {}),
                _buildQuickActionButton('View Documents', Icons.description, Colors.grey[700]!, () {}),
                _buildQuickActionButton('Log Time', Icons.access_time, Colors.grey[700]!, () {}),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        title,
        style: const TextStyle(fontSize: 11),
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: const Size(0, 32),
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, ProjectData project) {
    Navigator.of(context).pop(); // Close the detail dialog first
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProjectDialog(
          project: project,
          clientData: widget.clientData,
          onSave: (updatedProject) {
            widget.onProjectUpdate(project.id, updatedProject);
            setState(() {}); // Refresh the UI
          },
        );
      },
    );
  }
}

class EditProjectDialog extends StatefulWidget {
  final ProjectData project;
  final Map<String, ClientData> clientData;
  final Function(ProjectData) onSave;

  const EditProjectDialog({
    Key? key,
    required this.project,
    required this.clientData,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late TextEditingController _notesController;
  late TextEditingController _dueDateController;
  late TextEditingController _progressController;
  
  late ProjectStatus _selectedStatus;
  late Priority _selectedPriority;
  late String _selectedClient;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _descriptionController = TextEditingController(text: widget.project.description);
    _budgetController = TextEditingController(text: widget.project.budget);
    _notesController = TextEditingController(text: widget.project.notes);
    _dueDateController = TextEditingController(text: widget.project.dueDate);
    _progressController = TextEditingController(text: widget.project.progress.toString());
    
    _selectedStatus = widget.project.status;
    _selectedPriority = widget.project.priority;
    _selectedClient = widget.project.client;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    _dueDateController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[700]!),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: accentCyan, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Edit Project',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textWhite,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Title
                      _buildSectionTitle('Project Details'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Project Title',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a project title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Client and Status Row
                      _buildSectionTitle('Project Settings'),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 500) {
                            return Column(
                              children: [
                                _buildClientDropdown(),
                                const SizedBox(height: 16),
                                _buildStatusDropdown(),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(child: _buildClientDropdown()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildStatusDropdown()),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Priority and Progress Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 500) {
                            return Column(
                              children: [
                                _buildPriorityDropdown(),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _progressController,
                                  label: 'Progress (%)',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter progress';
                                    }
                                    final progress = int.tryParse(value);
                                    if (progress == null || progress < 0 || progress > 100) {
                                      return 'Progress must be between 0 and 100';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(child: _buildPriorityDropdown()),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _progressController,
                                    label: 'Progress (%)',
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter progress';
                                      }
                                      final progress = int.tryParse(value);
                                      if (progress == null || progress < 0 || progress > 100) {
                                        return 'Progress must be between 0 and 100';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Budget and Due Date
                      _buildSectionTitle('Timeline & Budget'),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 500) {
                            return Column(
                              children: [
                                _buildTextField(
                                  controller: _budgetController,
                                  label: 'Budget',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter budget';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _dueDateController,
                                  label: 'Due Date',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter due date';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _budgetController,
                                    label: 'Budget',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter budget';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _dueDateController,
                                    label: 'Due Date',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter due date';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Notes
                      _buildSectionTitle('Additional Notes'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _notesController,
                        label: 'Notes',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[700]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentCyan,
                      foregroundColor: textWhite,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: accentCyan,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: textWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentCyan),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildClientDropdown() {
    final clientNames = widget.clientData.values.map((client) => client.name).toList();
    
    return DropdownButtonFormField<String>(
      value: _selectedClient,
      style: const TextStyle(color: textWhite),
      decoration: InputDecoration(
        labelText: 'Client',
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentCyan),
        ),
      ),
      dropdownColor: bgSecondary,
      items: clientNames.map((clientName) {
        return DropdownMenuItem<String>(
          value: clientName,
          child: Text(clientName, style: const TextStyle(color: textWhite)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedClient = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a client';
        }
        return null;
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<ProjectStatus>(
      value: _selectedStatus,
      style: const TextStyle(color: textWhite),
      decoration: InputDecoration(
        labelText: 'Status',
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentCyan),
        ),
      ),
      dropdownColor: bgSecondary,
      items: ProjectStatus.values.map((status) {
        return DropdownMenuItem<ProjectStatus>(
          value: status,
          child: Text(
            getStatusText(status),
            style: TextStyle(color: getStatusColor(status)),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<Priority>(
      value: _selectedPriority,
      style: const TextStyle(color: textWhite),
      decoration: InputDecoration(
        labelText: 'Priority',
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentCyan),
        ),
      ),
      dropdownColor: bgSecondary,
      items: Priority.values.map((priority) {
        return DropdownMenuItem<Priority>(
          value: priority,
          child: Text(
            getPriorityText(priority),
            style: TextStyle(color: getPriorityColor(priority)),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      final updatedProject = ProjectData(
        id: widget.project.id,
        title: _titleController.text,
        description: _descriptionController.text,
        client: _selectedClient,
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _dueDateController.text,
        completedDate: _selectedStatus == ProjectStatus.completed 
            ? widget.project.completedDate ?? DateTime.now().toString().split(' ')[0]
            : null,
        budget: _budgetController.text,
        progress: int.tryParse(_progressController.text) ?? 0,
        timeSpent: widget.project.timeSpent,
        notes: _notesController.text,
        tasks: widget.project.tasks, clientId: '',
      );

      widget.onSave(updatedProject);
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}