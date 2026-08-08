import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import '../models/profile_models.dart';

class RewardsSection extends StatelessWidget {
  const RewardsSection({Key? key}) : super(key: key);

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
          // PERUBAHAN: Tinggi ditambahin dari 130 jadi 160 biar muat teks 2 baris
          height: 160,
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
        border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid),
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
          // PERUBAHAN: Ditambahin maxLines biar rapi dan ga bablas ke bawah
          Text(
            reward.title, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text('${reward.points} pts', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}