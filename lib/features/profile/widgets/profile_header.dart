import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import '../models/profile_models.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile user;
  final bool isUploading;
  final VoidCallback onEditImage;

  const ProfileHeader({
    Key? key, 
    required this.user, 
    required this.isUploading,
    required this.onEditImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = user.imageUrl.startsWith('http');

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onEditImage,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: isNetworkImage
                          ? NetworkImage(user.imageUrl) as ImageProvider
                          : AssetImage(user.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: isUploading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE9DCC9), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFF967E61), size: 16),
                const SizedBox(width: 4),
                Text(
                  user.tier,
                  style: const TextStyle(color: Color(0xFF967E61), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}