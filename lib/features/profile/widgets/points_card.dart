import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/services/language_service.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import '../models/profile_models.dart';

class PointsCard extends StatelessWidget {
  final UserProfile user;
  const PointsCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    double totalProgressGoal = (user.availablePoints + user.pointsToNextTier).toDouble();
    double progress = totalProgressGoal > 0
        ? (user.availablePoints / totalProgressGoal).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.tr('available_points'),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.availablePoints.toString(),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              AnimatedTouchable(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur tukar poin segera hadir!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur tukar poin segera hadir!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(lang.tr('redeem'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user.tier, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(
                '${user.pointsToNextTier} ${lang.tr('pts_to_next')} ${user.nextTierName}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}