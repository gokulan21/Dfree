// Update your existing project_detail_dialog.dart
import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../utils/constants.dart';
import 'progress_update_dialog.dart';

class ProjectDetailDialog extends StatelessWidget {
  final ProjectModel project;
  final bool isFreelancer;
  final VoidCallback? onApply;
  final VoidCallback? onProgressUpdated;

  const ProjectDetailDialog({
    super.key,
    required this.project,
    this.isFreelancer = false,
    this.onApply,
    this.onProgressUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentCyan.withOpacity(0.1),
                    AppColors.accentPink.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(project.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                project.statusDisplayName,
                                style: TextStyle(
                                  color: _getStatusColor(project.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '\$${project.budget.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Progress Section (Enhanced for freelancers)
                    if (isFreelancer && project.status == ProjectStatus.inProgress) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Project Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (project.progress < 100)
                            TextButton.icon(
                              onPressed: () => _showProgressUpdateDialog(context),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Update'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.accentCyan,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Progress Bar with percentage
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Progress',
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${project.progress}%',
                                  style: TextStyle(
                                    color: project.progress == 100 
                                        ? AppColors.successGreen 
                                        : AppColors.accentCyan,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: project.progress / 100,
                                backgroundColor: AppColors.borderColor,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  project.progress == 100 
                                      ? AppColors.successGreen 
                                      : AppColors.accentCyan,
                                ),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Progress milestones
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [25, 50, 75, 100].map((milestone) {
                                final isReached = project.progress >= milestone;
                                final isCurrent = project.progress < milestone && 
                                    (milestone == 25 || project.progress >= milestone - 25);
                                
                                return Column(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isReached 
                                            ? (milestone == 100 ? AppColors.successGreen : AppColors.accentCyan)
                                            : (isCurrent ? AppColors.warningYellow : AppColors.borderColor),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isReached 
                                            ? Icons.check 
                                            : (isCurrent ? Icons.radio_button_unchecked : Icons.circle),
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$milestone%',
                                      style: TextStyle(
                                        color: isReached 
                                            ? Colors.white 
                                            : AppColors.textGrey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else if (project.progress > 0) ...[
                      // Regular progress display for clients
                      const Text(
                        'Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: project.progress / 100,
                        backgroundColor: AppColors.borderColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${project.progress}% Complete',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Project Details
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem('Budget', '\$${project.budget.toStringAsFixed(0)}'),
                        ),
                        Expanded(
                          child: _buildDetailItem('Status', project.statusDisplayName),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem('Created', _formatDate(project.createdAt)),
                        ),
                        Expanded(
                          child: _buildDetailItem('Due Date', _formatDate(project.dueDate)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Skills if available
                    if (project.skills.isNotEmpty) ...[
                      const Text(
                        'Required Skills',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: project.skills.map((skill) {
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
                      const SizedBox(height: 16),
                    ],

                    // Payment info if available
                    if (project.paidAmount != null && project.paidAmount! > 0) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem('Paid Amount', '\$${project.paidAmount!.toStringAsFixed(0)}'),
                          ),
                          Expanded(
                            child: _buildDetailItem('Remaining', '\$${(project.budget - project.paidAmount!).toStringAsFixed(0)}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            if (isFreelancer && project.status == ProjectStatus.pending) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onApply?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCyan,
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderColor),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showProgressUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProgressUpdateDialog(
        project: project,
        onProgressUpdated: onProgressUpdated,
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return AppColors.warningYellow;
      case ProjectStatus.inProgress:
        return AppColors.accentCyan;
      case ProjectStatus.completed:
        return AppColors.successGreen;
      case ProjectStatus.cancelled:
        return AppColors.dangerRed;
      case ProjectStatus.onHold:
        return AppColors.textGrey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
