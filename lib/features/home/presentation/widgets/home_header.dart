import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/services/notification_service.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import 'package:restauran_app/features/profile/pages/notifications_page.dart';

class HomeHeader extends StatelessWidget {
  final String address;
  final String userName;
  final String? imageUrl;

  const HomeHeader({
    Key? key,
    required this.address,
    required this.userName,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifService = NotificationService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.place, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                address,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListenableBuilder(
              listenable: notifService,
              builder: (context, _) {
                return AnimatedTouchable(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsPage()),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Badge(
                      isLabelVisible: notifService.unreadCount > 0,
                      label: Text(
                        notifService.unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 9),
                      ),
                      backgroundColor: Colors.red,
                      child: Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 22),
                    ),
                  ),
                );
              },
            ),
            ClipOval(
              child: imageUrl != null && imageUrl!.startsWith('http')
                  ? Image.network(imageUrl!, width: 42, height: 42, fit: BoxFit.cover)
                  : Image.asset("assets/images/sate.jpg", width: 42, height: 42, fit: BoxFit.cover),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text("Hello $userName", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const Text("What are you Eating Today?", style: TextStyle(fontSize: 15, color: Colors.grey)),
      ],
    );
  }
}