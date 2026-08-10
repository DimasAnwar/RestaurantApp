import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

import 'core/theme/app_theme.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/regist_page.dart';
import 'features/dashboard/presentation/pages/main_dashboard_page.dart';
import 'features/admin/pages/admin_dashboard_page.dart'; // <-- JANGAN LUPA IMPORT ADMIN PAGE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodApp',
      initialRoute: '/',
      theme: AppTheme.lightTheme, 
      
      // PERUBAHAN: Pakai onGenerateRoute buat intercept perpindahan halaman
      onGenerateRoute: (settings) {
        final user = supabase.auth.currentUser;
        // Ambil role buat dipake di bawah
        final role = user?.userMetadata?['role'] ?? 'customer'; 
        
        // Daftar halaman yang BOLEH diakses walaupun belum login
        final isPublicRoute = settings.name == '/' || 
                              settings.name == '/onboarding' || 
                              settings.name == '/login' || 
                              settings.name == '/regist';

        // 1. CEK: Kalau belum login TAPI maksa masuk rute private -> Redirect ke Login
        if (user == null && !isPublicRoute) {
          return MaterialPageRoute(builder: (context) => const LoginPage());
        }

        // 2. CEK: Kalau UDAH login TAPI iseng buka halaman publik lagi -> Redirect sesuai ROLE
        if (user != null && (settings.name == '/login' || settings.name == '/regist' || settings.name == '/onboarding')) {
          if (role == 'admin') {
            return MaterialPageRoute(builder: (context) => const AdminDashboardPage());
          } else {
            return MaterialPageRoute(builder: (context) => const MainDashboardPage());
          }
        }

        // 3. Mapping rute normal kalau lolos pengecekan di atas
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const SplashPage());
          case '/onboarding':
            return MaterialPageRoute(builder: (context) => const OnboardingPage());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/regist':
            return MaterialPageRoute(builder: (context) => const RegistPage());
          case '/dashboard':
            // Cek role lagi kalau dipanggil pakai pushNamed('/dashboard')
            if (role == 'admin') {
              return MaterialPageRoute(builder: (context) => const AdminDashboardPage());
            } else {
              return MaterialPageRoute(builder: (context) => const MainDashboardPage());
            }
          default:
            return MaterialPageRoute(builder: (context) => const SplashPage());
        }
      },
    );
  }
}