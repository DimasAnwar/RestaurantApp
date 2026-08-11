import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/services/language_service.dart';
import 'package:restauran_app/core/services/notification_service.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import 'package:restauran_app/features/profile/pages/notifications_page.dart';

import '../models/profile_models.dart';
import '../widgets/profile_header.dart';
import '../widgets/points_card.dart';
import '../widgets/rewards_section.dart';
import '../widgets/menu_section.dart';

class ProfilePage extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const ProfilePage({Key? key, this.onSwitchTab}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'User';
  String _profileImageUrl = 'assets/images/sate.jpg';
  int _userPoints = 0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.userMetadata?['username'] ?? 'User';
        if (user.userMetadata?['avatar_url'] != null) {
          _profileImageUrl = user.userMetadata?['avatar_url'];
        }
        _userPoints = (user.userMetadata?['points'] as num?)?.toInt() ?? 0;
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    try {
      final picker = ImagePicker();
      final imageFile = await picker.pickImage(source: ImageSource.gallery);
      if (imageFile == null) return;

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      setState(() => _isUploading = true);

      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mengunggah gambar...'), duration: Duration(seconds: 1)),
      );

      await Supabase.instance.client.storage
          .from('users_profile')
          .uploadBinary(fileName, bytes);

      final publicUrl = Supabase.instance.client.storage
          .from('users_profile')
          .getPublicUrl(fileName);

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'avatar_url': publicUrl}),
      );

      setState(() {
        _profileImageUrl = publicUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Error upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengunggah foto.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // Helper tier calculation
  Map<String, dynamic> _calculateTier(int points) {
    if (points < 100) {
      return {'tier': 'NEW MEMBER', 'pointsToNext': 100 - points, 'nextTier': 'Bronze'};
    } else if (points < 500) {
      return {'tier': 'BRONZE MEMBER', 'pointsToNext': 500 - points, 'nextTier': 'Silver'};
    } else if (points < 1500) {
      return {'tier': 'SILVER MEMBER', 'pointsToNext': 1500 - points, 'nextTier': 'Gold VIP'};
    } else {
      return {'tier': 'GOLD VIP', 'pointsToNext': 0, 'nextTier': 'Max Tier'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final notifService = NotificationService.instance;
    final tierInfo = _calculateTier(_userPoints);

    final currentUserData = UserProfile(
      name: _userName,
      tier: tierInfo['tier'],
      imageUrl: _profileImageUrl,
      availablePoints: _userPoints,
      pointsToNextTier: tierInfo['pointsToNext'],
      nextTierName: tierInfo['nextTier'],
    );

    return ListenableBuilder(
      listenable: Listenable.merge([lang, notifService]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAF8F5),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _ProfileAppBar(
                    title: lang.tr('profile'),
                    unreadNotifCount: notifService.unreadCount,
                    onOpenNotif: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsPage()),
                      ).then((_) => _getUserData());
                    },
                  ),
                  const SizedBox(height: 30),
                  ProfileHeader(
                    user: currentUserData,
                    isUploading: _isUploading,
                    onEditImage: _uploadProfileImage,
                  ),
                  const SizedBox(height: 30),
                  PointsCard(user: currentUserData),
                  const SizedBox(height: 30),
                  const RewardsSection(),
                  const SizedBox(height: 30),
                  MenuSection(onSwitchTab: widget.onSwitchTab),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  final String title;
  final int unreadNotifCount;
  final VoidCallback onOpenNotif;

  const _ProfileAppBar({
    Key? key,
    required this.title,
    required this.unreadNotifCount,
    required this.onOpenNotif,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8D4B3F)),
        ),
        AnimatedTouchable(
          onTap: onOpenNotif,
          child: Badge(
            isLabelVisible: unreadNotifCount > 0,
            label: Text(unreadNotifCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
            backgroundColor: Colors.red,
            child: Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 28),
          ),
        ),
      ],
    );
  }
}