import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'custom_card.dart';

class FreelancerCard extends StatelessWidget {
  final UserModel freelancer;
  final VoidCallback? onTap;

  const FreelancerCard({
    super.key,
    required this.freelancer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accentCyan, AppColors.accentPink],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      freelancer.name.isNotEmpty ? freelancer.name[0].toUpperCase() : 'F',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        freelancer.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < freelancer.rating.floor()
                                  ? Icons.star
                                  : (index < freelancer.rating ? Icons.star_half : Icons.star_border),
                              color: Colors.amber,
                              size: 14,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            freelancer.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  child: Text(
                    '\$${freelancer.hourlyRate.toStringAsFixed(0)}/hr',
                    style: const TextStyle(
                      color: AppColors.successGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Bio
            if (freelancer.bio != null && freelancer.bio!.isNotEmpty) ...[
              Text(
                freelancer.bio!,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],
            
            // Skills
            if (freelancer.skills.isNotEmpty) ...[
              SizedBox(
                height: 26,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: freelancer.skills.length > 4 ? 4 : freelancer.skills.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    if (index == 3 && freelancer.skills.length > 4) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.textGrey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${freelancer.skills.length - 3}',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return Container(
                      constraints: const BoxConstraints(maxWidth: 80),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        freelancer.skills[index],
                        style: const TextStyle(
                          color: AppColors.accentCyan,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStat('Projects', freelancer.completedProjects.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStat('Success Rate', '${_getSuccessRate()}%'),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAvailabilityColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getAvailabilityText(),
                    style: TextStyle(
                      color: _getAvailabilityColor(),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  int _getSuccessRate() {
    if (freelancer.totalProjects == 0) return 0;
    return ((freelancer.completedProjects / freelancer.totalProjects) * 100).round();
  }

  Color _getAvailabilityColor() {
    // Simple availability logic - can be enhanced
    return freelancer.totalProjects < 5 ? AppColors.successGreen : AppColors.warningYellow;
  }

  String _getAvailabilityText() {
    return freelancer.totalProjects < 5 ? 'Available' : 'Busy';
  }
}

class FreelancerListCard extends StatelessWidget {
  final UserModel freelancer;
  final VoidCallback? onTap;

  const FreelancerListCard({
    super.key,
    required this.freelancer,
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
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accentCyan, AppColors.accentPink],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  freelancer.name.isNotEmpty ? freelancer.name[0].toUpperCase() : 'F',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    freelancer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < freelancer.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 12,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        freelancer.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  child: Text(
                    '\$${freelancer.hourlyRate.toStringAsFixed(0)}/hr',
                    style: const TextStyle(
                      color: AppColors.successGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${freelancer.completedProjects} projects',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}