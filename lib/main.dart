import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/regist_page.dart';
import 'features/home/presentation/pages/main_dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodApp',

      initialRoute: '/',

      routes: {
        '/' : (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/regist':(context) => const RegistPage(),
        '/dashboard':(context) => const MainDashboardPage()
      },
      
      // INI DIA KUNCINYA! Seluruh aplikasi lu otomatis ngikutin tema ini
      theme: AppTheme.lightTheme, 
      
    );
  }
}