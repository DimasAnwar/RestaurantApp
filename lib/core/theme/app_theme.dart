import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Inter', 
      
      scaffoldBackgroundColor: AppColors.background,
      
      primaryColor: AppColors.primary,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
    );
  }
}
