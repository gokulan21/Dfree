import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../utils/constants.dart';
import 'custom_card.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final bool showApplyButton;
  final VoidCallback? onApply;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.showApplyButton = false,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.clientName,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(project.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
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
            ],
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            project.description,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          // Skills
          if (project.skills.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.skills.take(3).map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      color: AppColors.accentCyan,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
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
              if (!showApplyButton)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${project.progress}%',
                      style: const TextStyle(
                        color: AppColors.accentCyan,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Apply'),
                ),
            ],
          ),
          
          // Progress bar (only for assigned projects)
          if (!showApplyButton && project.progress > 0) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: project.progress / 100,
              backgroundColor: AppColors.borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
            ),
          ],
          
          // Due date
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.grey[400],
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Due: ${project.dueDate.formatDate}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
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
}

class ProjectListCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;

  const ProjectListCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: _getStatusColor(project.status),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.clientName,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: project.progress / 100,
                    backgroundColor: AppColors.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(project.status)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${project.budget.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${project.progress}%',
                  style: TextStyle(
                    color: _getStatusColor(project.status),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
}
