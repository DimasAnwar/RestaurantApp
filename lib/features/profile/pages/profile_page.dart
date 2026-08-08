import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restauran_app/core/theme/app_colors.dart';

// Import model & widgets yang barusan dipisah
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
  String _profileImageUrl = 'assets/images/sate.jpg'; // Default lokal
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
      });
    }
  }

  // --- FUNGSI UPLOAD FOTO PROFIL KE BUCKET SUPABASE ---
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

      // Upload ke bucket 'users_profile'
      await Supabase.instance.client.storage
          .from('users_profile')
          .uploadBinary(fileName, bytes);

      // Ambil public URL-nya
      final publicUrl = Supabase.instance.client.storage
          .from('users_profile')
          .getPublicUrl(fileName);

      // Update metadata user
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'avatar_url': publicUrl}),
      );

      setState(() {
        _profileImageUrl = publicUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      debugPrint('Error upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengunggah foto.'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserData = UserProfile(
      name: _userName,
      tier: 'NEW MEMBER', 
      imageUrl: _profileImageUrl,
      availablePoints: 0, 
      pointsToNextTier: 100, 
      nextTierName: 'Silver', 
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const _ProfileAppBar(),
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
  }
}

// Komponen kecil dibiarin di sini biar ga terlalu banyak file
class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8D4B3F)),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 28),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}