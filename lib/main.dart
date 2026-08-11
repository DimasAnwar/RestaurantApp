import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/services/language_service.dart';
import 'core/services/notification_service.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/regist_page.dart';
import 'features/dashboard/presentation/pages/main_dashboard_page.dart';
import 'features/admin/pages/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Inisialisasi service bahasa & notifikasi
  await LanguageService.instance.init();
  await NotificationService.instance.init();

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RestaurantApp',
          initialRoute: '/',
          theme: AppTheme.lightTheme,
          onGenerateRoute: (settings) {
            final user = supabase.auth.currentUser;
            final role = user?.userMetadata?['role'] ?? 'customer';

            final isPublicRoute = settings.name == '/' ||
                settings.name == '/onboarding' ||
                settings.name == '/login' ||
                settings.name == '/regist';

            if (user == null && !isPublicRoute) {
              return MaterialPageRoute(builder: (context) => const LoginPage());
            }

            if (user != null &&
                (settings.name == '/login' || settings.name == '/regist' || settings.name == '/onboarding')) {
              if (role == 'admin') {
                return MaterialPageRoute(builder: (context) => const AdminDashboardPage());
              } else {
                return MaterialPageRoute(builder: (context) => const MainDashboardPage());
              }
            }

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
      },
    );
  }
}