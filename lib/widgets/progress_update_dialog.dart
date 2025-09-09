// Create: lib/widgets/progress_update_dialog.dart
import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class ProgressUpdateDialog extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback? onProgressUpdated;

  const ProgressUpdateDialog({
    super.key,
    required this.project,
    this.onProgressUpdated,
  });

  @override
  State<ProgressUpdateDialog> createState() => _ProgressUpdateDialogState();
}

class _ProgressUpdateDialogState extends State<ProgressUpdateDialog> {
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  
  int _selectedProgress = 0;
  bool _isUpdating = false;
  String? _error;

  final List<int> _progressOptions = [25, 50, 75, 100];

  @override
  void initState() {
    super.initState();
    _selectedProgress = widget.project.progress;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppColors.accentCyan,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Update Progress',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textGrey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Project info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Client: ${widget.project.clientName}',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Current Progress
            Text(
              'Current Progress: ${widget.project.progress}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // Progress Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                widthFactor: widget.project.progress / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress Options
            const Text(
              'Update to:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Progress Buttons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: _progressOptions.map((progress) {
                final isSelected = _selectedProgress == progress;
                final isDisabled = progress <= widget.project.progress;
                final isCompleted = progress == 100;
                
                return GestureDetector(
                  onTap: isDisabled ? null : () {
                    setState(() {
                      _selectedProgress = progress;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isCompleted ? AppColors.successGreen.withOpacity(0.2) : AppColors.accentCyan.withOpacity(0.2))
                          : (isDisabled ? AppColors.borderColor.withOpacity(0.3) : AppColors.bgSecondary),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (isCompleted ? AppColors.successGreen : AppColors.accentCyan)
                            : (isDisabled ? AppColors.borderColor : AppColors.textGrey),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected
                              ? (isCompleted ? AppColors.successGreen : AppColors.accentCyan)
                              : (isDisabled ? AppColors.borderColor : AppColors.textGrey),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$progress%',
                          style: TextStyle(
                            color: isSelected
                                ? (isCompleted ? AppColors.successGreen : AppColors.accentCyan)
                                : (isDisabled ? AppColors.borderColor : Colors.white),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Complete',
                            style: TextStyle(
                              color: isSelected ? AppColors.successGreen : AppColors.textGrey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            if (_selectedProgress == 100) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.successGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.successGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Marking as 100% will complete the project and notify the client.',
                        style: const TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.dangerRed.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.dangerRed,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isUpdating ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderColor),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_isUpdating || _selectedProgress <= widget.project.progress) 
                        ? null 
                        : _updateProgress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedProgress == 100 
                          ? AppColors.successGreen 
                          : AppColors.accentCyan,
                      foregroundColor: Colors.white,
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_selectedProgress == 100 ? 'Complete Project' : 'Update Progress'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProgress() async {
    setState(() {
      _isUpdating = true;
      _error = null;
    });

    try {
      final currentUser = await _authService.getCurrentUserData();
      if (currentUser == null) throw Exception('User not found');

      await _projectService.updateProjectProgressWithNotification(
        projectId: widget.project.id,
        progress: _selectedProgress,
        freelancerName: currentUser.name,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onProgressUpdated?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedProgress == 100 
                  ? 'Project completed! Client has been notified.' 
                  : 'Progress updated to $_selectedProgress%',
            ),
            backgroundColor: _selectedProgress == 100 
                ? AppColors.successGreen 
                : AppColors.accentCyan,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isUpdating = false;
      });
    }
  }
}
