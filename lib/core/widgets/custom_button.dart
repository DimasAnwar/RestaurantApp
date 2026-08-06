import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Ganti jadi StatelessWidget biar lebih ringan dan gampang dipanggil
class CustomButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double? width;

  const CustomButton({
     super.key,
     required this.text,
     required this.onPressed,
     this.isPrimary = true,
     this.width, 
     });

  @override
  Widget build(BuildContext context) {
    // Karena Stateless, kita bisa langsung panggil 'width', 'onPressed', dll
    final buttonWidth = width ?? MediaQuery.of(context).size.width * 0.85;
    
    return SizedBox(
       width: buttonWidth,
      height: 55, // Fixed height to maintain consistency across the app
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          // Dynamic Background Color based on isPrimary
          backgroundColor: isPrimary ? AppColors.primary : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            // Dynamic Border based on isPrimary
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: "Inter",
            fontSize: 18,
            fontWeight: FontWeight.bold,
            // Dynamic Text Color based on isPrimary
            color: isPrimary ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}