import 'package:flutter/material.dart';
import 'package:muhasabah/features/splash/splash_screen.dart';
import 'package:muhasabah/app/main_shell.dart';
import 'package:muhasabah/features/onboarding/onboarding_screen.dart';
import 'package:muhasabah/features/prayer/presentation/screens/prayer_screen.dart';
import 'package:muhasabah/features/adhkar/adhkar _screen.dart';
import 'package:muhasabah/features/settings/presentation/screens/about_me_screen.dart';
import 'package:muhasabah/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:muhasabah/features/duas/presentation/screens/duas_screen.dart';
import 'package:muhasabah/features/asma/presentation/screens/asma_screen.dart';
import 'package:muhasabah/features/auth/presentation/screens/auth_screen.dart';
import 'package:muhasabah/features/achievements/presentation/screens/achievements_screen.dart';

/// Defines all the route names used in the application.
class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String checklist = '/checklist';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String aboutMe = '/about-me';
  static const String onboarding = '/onboarding';
  static const String prayer = '/prayer';
  static const String adhkar = '/adhkar';
  static const String qibla = '/qibla';
  static const String duas = '/duas';
  static const String asma = '/asma';
  static const String auth = '/auth';
  static const String achievements = '/achievements';
}

/// Centralized route generation and management.
class AppRoutes {
  /// Handles routing mapping for all named routes in the app.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const MainShell());
      case Routes.checklist:
        return MaterialPageRoute(
          builder: (_) => const MainShell(initialIndex: 1),
        );
      case Routes.statistics:
        return MaterialPageRoute(
          builder: (_) => const MainShell(initialIndex: 2),
        );
      case Routes.settings:
        return MaterialPageRoute(
          builder: (_) => const MainShell(initialIndex: 3),
        );
      case Routes.aboutMe:
        return MaterialPageRoute(builder: (_) => const AboutMeScreen());
      case Routes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case Routes.prayer:
        return MaterialPageRoute(builder: (_) => const PrayerScreen());
      case Routes.adhkar:
        final args = settings.arguments;
        final index = args is int ? args : 0;
        return MaterialPageRoute(
          builder: (_) => AdhkarScreen(initialCategoryIndex: index),
        );
      case Routes.qibla:
        return MaterialPageRoute(builder: (_) => const QiblaScreen());
      case Routes.duas:
        return MaterialPageRoute(builder: (_) => const DuasScreen());
      case Routes.asma:
        return MaterialPageRoute(builder: (_) => const AsmaScreen());
      case Routes.auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case Routes.achievements:
        return MaterialPageRoute(builder: (_) => const AchievementsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
