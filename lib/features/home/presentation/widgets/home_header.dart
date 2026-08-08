import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String address;
  final String userName;
  final String? imageUrl;

  const HomeHeader({Key? key, required this.address, required this.userName, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.place, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(address, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            ClipOval(
              child: imageUrl != null && imageUrl!.startsWith('http')
                  ? Image.network(imageUrl!, width: 45, height: 45, fit: BoxFit.cover)
                  : Image.asset("assets/images/sate.jpg", width: 45, height: 45, fit: BoxFit.cover),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text("Hello $userName", style: const TextStyle(fontSize: 33, fontWeight: FontWeight.bold)),
        const Text("What are you Eating Today?", style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}