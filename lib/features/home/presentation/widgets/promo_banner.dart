import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(width: double.infinity, child: Image.asset("assets/images/promo1.jpg", fit: BoxFit.cover)),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.5)]),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20, top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
              child: const Text("Special Offers", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          const Positioned(
            bottom: 20, left: 20,
            child: Text("50% Off \nFirst Order", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}