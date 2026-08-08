import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restauran_app/core/theme/app_colors.dart';

// Import halaman lain buat navigasi menu
import 'delivery_address_page.dart';
import 'settings_page.dart';
import 'order_page.dart'; // Sesuaikan path ini

class UserProfile {
  final String name;
  final String tier;
  final String imageUrl;
  final int availablePoints;
  final int pointsToNextTier;
  final String nextTierName;

  UserProfile({
    required this.name,
    required this.tier,
    required this.imageUrl,
    required this.availablePoints,
    required this.pointsToNextTier,
    required this.nextTierName,
  });
}

class RewardOption {
  final String title;
  final int points;
  final IconData icon;

  RewardOption({
    required this.title,
    required this.points,
    required this.icon,
  });
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

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
    // Sesuai request: Poin untuk user baru = 0
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
              
              // Widget Header dilempar fungsi onEditImage
              _ProfileHeader(
                user: currentUserData, 
                isUploading: _isUploading,
                onEditImage: _uploadProfileImage,
              ),
              
              const SizedBox(height: 30),
              _PointsCard(user: currentUserData),
              const SizedBox(height: 30),
              const _RewardsSection(),
              const SizedBox(height: 30),
              const _MenuSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _ProfileHeader extends StatelessWidget {
  final UserProfile user;
  final bool isUploading;
  final VoidCallback onEditImage;

  const _ProfileHeader({
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
          // Gambar Profil + Ikon Kamera
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

class _PointsCard extends StatelessWidget {
  final UserProfile user;
  const _PointsCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = user.availablePoints / (user.availablePoints + user.pointsToNextTier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
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
                  const Text('Available Points', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    user.availablePoints.toString(),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Redeem', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user.tier, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text('${user.pointsToNextTier} pts to ${user.nextTierName}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

class _RewardsSection extends StatelessWidget {
  const _RewardsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<RewardOption> rewards = [
      RewardOption(title: 'Voucher Kopi Gratis', points: 300, icon: Icons.local_cafe_rounded),
      RewardOption(title: 'Diskon 50% Makanan', points: 500, icon: Icons.percent_rounded),
      RewardOption(title: 'Gratis Ongkir', points: 150, icon: Icons.delivery_dining_rounded),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Voucher Rewards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {},
              child: Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: rewards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _RewardCard(reward: rewards[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final RewardOption reward;
  const _RewardCard({Key? key, required this.reward}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid), // Efek voucher
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFE9DCC9), shape: BoxShape.circle),
            child: Icon(reward.icon, color: const Color(0xFF8D4B3F), size: 28),
          ),
          const SizedBox(height: 12),
          Text(reward.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text('${reward.points} pts', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.assignment_outlined, 
          title: 'Order History', 
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderPage())),
        ),
        _MenuItem(
          icon: Icons.location_on_outlined, 
          title: 'Delivery Addresses',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryAddressPage())),
        ),
        _MenuItem(
          icon: Icons.settings_outlined, 
          title: 'Settings',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({Key? key, required this.icon, required this.title, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
        onTap: onTap, // Dipasang callback navigasi
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}