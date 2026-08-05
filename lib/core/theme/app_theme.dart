import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // 1. Set font utama aplikasi
      fontFamily: 'Inter', 
      
      // 2. Set warna background dasar
      scaffoldBackgroundColor: AppColors.background,
      
      // 3. Set warna utama
      primaryColor: AppColors.primary,
      
      // 4. Set warna Appbar global (kalau ada)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0, // Biar gak ada bayangan
      ),
      
      // (Bisa ditambahin tema tombol, tema text, dll nanti seiring jalan)
    );
  }
}