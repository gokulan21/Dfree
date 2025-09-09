import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../utils/constants.dart';

class ProjectDetailDialog extends StatelessWidget {
  final ProjectModel project;
  final bool isFreelancer;
  final VoidCallback? onApply;

  const ProjectDetailDialog({
    super.key,
    required this.project,
    this.isFreelancer = false,
    this.onApply,
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
                          child: _buildDetailItem('Progress', '${project.progress}%'),
                        ),
                        Expanded(
                          child: _buildDetailItem('Created', _formatDate(project.createdAt)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Updated date if available
                    // ignore: unnecessary_null_comparison
                    if (project.updatedAt != null) ...[
                      _buildDetailItem('Last Updated', _formatDate(project.updatedAt)),
                      const SizedBox(height: 16),
                    ],

                    // Client and Freelancer info if available
                    if (project.clientId.isNotEmpty) ...[
                      _buildDetailItem('Client ID', project.clientId),
                      const SizedBox(height: 16),
                    ],

                    if (project.freelancerId != null && project.freelancerId!.isNotEmpty) ...[
                      _buildDetailItem('Freelancer ID', project.freelancerId!),
                      const SizedBox(height: 16),
                    ],

                    // Progress Bar (if project is in progress)
                    if (project.status == ProjectStatus.inProgress) ...[
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