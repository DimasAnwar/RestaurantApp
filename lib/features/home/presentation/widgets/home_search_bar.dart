import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onMicTap;
  final Function(String) onSubmitted;

  const HomeSearchBar({Key? key, required this.controller, required this.isListening, required this.onMicTap, required this.onSubmitted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted, // Aksi pas user tekan Enter/Search di keyboard
              decoration: InputDecoration(
                hintText: 'Search for food, drinks etc.',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onMicTap,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: isListening ? Colors.red : AppColors.primary.withOpacity(0.1),
            child: Icon(isListening ? Icons.mic : Icons.mic_none, size: 28, color: isListening ? Colors.white : AppColors.primary),
          ),
        ),
      ],
    );
  }
}