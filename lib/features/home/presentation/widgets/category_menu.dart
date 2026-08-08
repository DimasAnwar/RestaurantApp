import 'package:flutter/material.dart';

class CategoryMenu extends StatelessWidget {
  final Function(int) onCategoryTap;

  const CategoryMenu({Key? key, required this.onCategoryTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(Icons.food_bank, "Food", () => onCategoryTap(0)),
          _buildItem(Icons.local_drink_rounded, "Drinks", () => onCategoryTap(1)),
          _buildItem(Icons.icecream_rounded, "Dessert", () => onCategoryTap(2)),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(color: const Color.fromARGB(255, 235, 184, 174), borderRadius: BorderRadius.circular(15)),
          child: IconButton(
            onPressed: onTap, // Aksi klik kategori
            icon: Icon(icon, size: 36, color: const Color.fromARGB(255, 85, 27, 13)),
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Inter'))
      ],
    );
  }
}