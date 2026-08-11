import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';

class AdminHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const AdminHeader({
    Key? key,
    this.onNotificationTap,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFFFBF8),
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          AnimatedTouchable(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: const AssetImage('assets/images/user1.jpg'),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Magic Food Admin',
              style: TextStyle(
                color: const Color(0xFFB82810),
                fontWeight: FontWeight.w900,
                fontSize: 19,
                letterSpacing: -0.3,
              ),
            ),
          ),
          AnimatedTouchable(
            onTap: onNotificationTap,
            child: Badge(
              isLabelVisible: true,
              backgroundColor: AppColors.primary,
              smallSize: 8,
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.black87,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
