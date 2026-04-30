import 'package:flutter/material.dart';
import 'package:takwa/features/books/presentation/screens/books_library_screen.dart';
import 'package:takwa/features/books/presentation/screens/books_chapter_screen.dart';
import 'package:takwa/features/books/presentation/screens/book_pdf_reader_screen.dart';
import 'package:takwa/features/books/data/books_data.dart';
import 'package:takwa/features/adhkar/presentation/screens/favorite_adhkar_screen.dart';
import 'package:takwa/features/prayer/presentation/screens/mosques_screen.dart';
import 'package:takwa/features/adhkar/presentation/screens/misbaha_screen.dart';

import 'package:takwa/features/asma/presentation/screens/asma_screen.dart';
import 'package:takwa/features/duas/presentation/screens/favorite_duas_screen.dart';
import 'package:takwa/features/splash/splash_screen.dart';
import 'package:takwa/app/main_shell.dart';
import 'package:takwa/features/onboarding/onboarding_screen.dart';
import 'package:takwa/features/auth/presentation/pages/auth_choice_screen.dart';
import 'package:takwa/features/prayer/presentation/screens/prayer_screen.dart';
import 'package:takwa/features/adhkar/presentation/screens/adhkar%20_screen.dart';
import 'package:takwa/features/settings/presentation/screens/about_me_screen.dart';
import 'package:takwa/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:takwa/features/duas/presentation/screens/duas_screen.dart';
import 'package:takwa/features/auth/presentation/screens/auth_screen.dart';
import 'package:takwa/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:takwa/features/profile/presentation/screens/profile_screen.dart';
import 'package:takwa/features/profile/presentation/screens/account_settings_screen.dart';
import 'package:takwa/features/quran/presentation/screens/quran_screen.dart';
import 'package:takwa/features/quran/presentation/screens/quran_reader_screen.dart';
import 'package:takwa/features/quran/presentation/screens/ai_memorize_screen.dart';
import 'package:takwa/features/quran/presentation/screens/create_khatma_screen.dart';
import 'package:takwa/features/quran/presentation/screens/free_reading_screen.dart';
import 'package:takwa/features/quran/presentation/screens/khatma_history_screen.dart';
import 'package:takwa/features/quran/presentation/screens/khatma_progress_screen.dart';
import 'package:takwa/features/quran/presentation/screens/khatma_progress_settings_screen.dart';
import 'package:takwa/features/quran/presentation/screens/khatma_settings_screen.dart';
import 'package:takwa/core/notifications/overlays/adhan_overlay_screen.dart';
import 'package:takwa/core/notifications/overlays/wake_up_overlay_screen.dart';
import 'package:takwa/features/settings/presentation/screens/terms_privacy_screen.dart';
import 'package:takwa/features/reminders/presentation/screens/reminders_list_screen.dart';
import 'package:takwa/features/checklist/screens/manage_custom_ibadah_screen.dart';
import 'package:takwa/features/settings/presentation/screens/subscription_screen.dart';
import 'package:takwa/features/settings/presentation/screens/payment_methods_screen.dart';
import 'package:takwa/features/qiyam/presentation/screens/qiyam_dashboard_screen.dart';
import 'package:takwa/features/qiyam/presentation/screens/qiyam_calculator_screen.dart';
import 'package:takwa/features/qiyam/presentation/screens/qiyam_stories_screen.dart';
import 'package:takwa/features/qiyam/presentation/screens/qiyam_wird_screen.dart';
import 'package:takwa/features/qiyam/presentation/screens/qiyam_virtues_screen.dart';
import 'package:takwa/features/qiyam/presentation/screens/qiyam_sleep_calculator_screen.dart';
import 'package:takwa/features/qiyam/presentation/screens/qiyam_beginner_guide_screen.dart';
import 'package:takwa/features/qiyam/presentation/screens/qiyam_sunnah_guide_screen.dart';
import 'package:takwa/features/auth/presentation/screens/email_confirmation_screen.dart';
import 'package:takwa/features/auth/presentation/screens/update_password_screen.dart';

/// Defines all the route names used in the application.
class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String checklist = '/checklist';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String accountSettings = '/account-settings';
  static const String aboutMe = '/about-me';
  static const String onboarding = '/onboarding';
  static const String prayer = '/prayer';
  static const String adhkar = '/adhkar';
  static const String qibla = '/qibla';
  static const String duas = '/duas';
  static const String asma = '/asma';
  static const String auth = '/auth';
  static const String achievements = '/achievements';
  static const String authChoice = '/auth-choice';
  static const String profile = '/profile';
  static const String quran = '/quran';
  static const String quranReader = '/quran-reader';
  static const String aiMemorize = '/quran/ai-memorize';
  static const String createKhatma = '/quran/create-khatma';
  static const String freeReading = '/quran/free-reading';
  static const String khatmaHistory = '/quran/khatma-history';
  static const String khatmaProgress = '/quran/khatma-progress';
  static const String khatmaProgressSettings =
      '/quran/khatma-progress-settings';
  static const String khatmaExtendedSettings =
      '/quran/khatma-extended-settings';
  static const String khatmaSettings = '/quran/khatma-settings';
  static const String adhan = '/adhan';
  static const String wakeUpOverlay = '/wake-up-overlay';
  static const String terms = '/terms';
  static const String reminders = '/reminders';
  static const String favoriteAdhkar = '/favorite-adhkar';
  static const String favoriteDuas = '/favorite-duas';
  static const String mosques = '/mosques';
  static const String misbaha = '/misbaha';
  static const String manageCustomIbadah = '/manage-custom-ibadah';
  static const String subscription = '/subscription';
  static const String paymentMethods = '/payment-methods';
  static const String qiyam = '/qiyam';
  static const String qiyamCalculator = '/qiyam-calculator';
  static const String qiyamStories = '/qiyam-stories';
  static const String qiyamWird = '/qiyam-wird';
  static const String qiyamVirtues = '/qiyam-virtues';
  static const String qiyamSleepCalculator = '/qiyam-sleep-calculator';
  static const String qiyamBeginnerGuide = '/qiyam-beginner-guide';
  static const String qiyamSunnahGuide = '/qiyam-sunnah-guide';
  static const String emailConfirmation = '/email-confirmation';
  static const String updatePassword = '/update-password';
  static const String books = '/books';
  static const String booksChapter = '/books/chapter';
  static const String booksPdf = '/books/pdf';
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
          builder: (_) => const MainShell(initialIndex: 2),
        );
      case Routes.statistics:
        return MaterialPageRoute(
          builder: (_) => const MainShell(initialIndex: 3),
        );
      case Routes.settings:
        return MaterialPageRoute(
          builder: (_) => const MainShell(initialIndex: 5),
        );
      case Routes.accountSettings:
        return MaterialPageRoute(builder: (_) => const AccountSettingsScreen());
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
      case Routes.authChoice:
        return MaterialPageRoute(builder: (_) => const AuthChoiceScreen());
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.quran:
        return MaterialPageRoute(builder: (_) => const QuranScreen());
      case Routes.quranReader:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => QuranReaderScreen(
            startFromKhatma: args?['startFromKhatma'] ?? false,
            initialSurah: args?['initialSurah'],
            initialPage: args?['initialPage'],
          ),
        );
      case Routes.aiMemorize:
        return MaterialPageRoute(builder: (_) => const AiMemorizeScreen());
      case Routes.createKhatma:
        return MaterialPageRoute(builder: (_) => const CreateKhatmaScreen());
      case Routes.freeReading:
        return MaterialPageRoute(builder: (_) => const FreeReadingScreen());
      case Routes.khatmaHistory:
        return MaterialPageRoute(builder: (_) => const KhatmaHistoryScreen());
      case Routes.khatmaProgress:
        return MaterialPageRoute(builder: (_) => const KhatmaProgressScreen());
      case Routes.khatmaProgressSettings:
        return MaterialPageRoute(
          builder: (_) => const KhatmaProgressSettingsScreen(),
        );
      case Routes.khatmaExtendedSettings:
        return MaterialPageRoute(
          builder: (_) => const KhatmaExtendedSettingsScreen(),
        );
      case Routes.khatmaSettings:
        return MaterialPageRoute(builder: (_) => const KhatmaSettingsScreen());
      case Routes.adhan:
        final prayerName = (settings.arguments as String?) ?? 'الصلاة';
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => AdhanOverlayScreen(prayerName: prayerName),
        );
      case Routes.wakeUpOverlay:
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const WakeUpOverlayScreen(),
        );
      case Routes.terms:
        return MaterialPageRoute(builder: (_) => const TermsPrivacyScreen());
      case Routes.reminders:
        return MaterialPageRoute(builder: (_) => const RemindersListScreen());
      case Routes.favoriteAdhkar:
        return MaterialPageRoute(builder: (_) => const FavoriteAdhkarScreen());
      case Routes.favoriteDuas:
        return MaterialPageRoute(builder: (_) => const FavoriteDuasScreen());
      case Routes.mosques:
        return MaterialPageRoute(builder: (_) => const MosquesScreen());
      case Routes.misbaha:
        return MaterialPageRoute(builder: (_) => const MisbahaScreen());
      case Routes.manageCustomIbadah:
        return MaterialPageRoute(
          builder: (_) => const ManageCustomIbadahScreen(),
        );
      case Routes.subscription:
        return MaterialPageRoute(builder: (_) => const SubscriptionScreen());
      case Routes.paymentMethods:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());
      case Routes.qiyam:
        return MaterialPageRoute(builder: (_) => const QiyamDashboardScreen());
      case Routes.qiyamCalculator:
        return MaterialPageRoute(builder: (_) => const QiyamCalculatorScreen());
      case Routes.qiyamStories:
        return MaterialPageRoute(builder: (_) => const QiyamStoriesScreen());
      case Routes.qiyamWird:
        return MaterialPageRoute(builder: (_) => const QiyamWirdScreen());
      case Routes.qiyamVirtues:
        return MaterialPageRoute(builder: (_) => const QiyamVirtuesScreen());
      case Routes.qiyamSleepCalculator:
        return MaterialPageRoute(
          builder: (_) => const QiyamSleepCalculatorScreen(),
        );
      case Routes.qiyamBeginnerGuide:
        return MaterialPageRoute(
          builder: (_) => const QiyamBeginnerGuideScreen(),
        );
      case Routes.qiyamSunnahGuide:
        return MaterialPageRoute(
          builder: (_) => const QiyamSunnahGuideScreen(),
        );
      case Routes.emailConfirmation:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => EmailConfirmationScreen(email: email),
        );
      case Routes.updatePassword:
        return MaterialPageRoute(builder: (_) => const UpdatePasswordScreen());
      case Routes.books:
        return MaterialPageRoute(builder: (_) => const BooksLibraryScreen());
      case Routes.booksChapter:
        final book = settings.arguments as IslamicBook;
        return MaterialPageRoute(
          builder: (_) => BooksChapterScreen(book: book),
        );
      case Routes.booksPdf:
        final book = settings.arguments as IslamicBook;
        return MaterialPageRoute(
          builder: (_) => BookPdfReaderScreen(book: book),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
