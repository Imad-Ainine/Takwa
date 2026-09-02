import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Achievement title: 3-day accountability streak
  ///
  /// In ar, this message translates to:
  /// **'البداية الطيبة'**
  String get achievementStreak3Title;

  /// Achievement description: 3-day accountability streak
  ///
  /// In ar, this message translates to:
  /// **'حافظت على المحاسبة لثلاثة أيام متواصلة'**
  String get achievementStreak3Desc;

  /// Achievement title: 7-day accountability streak
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع المثالي'**
  String get achievementStreak7Title;

  /// Achievement description: 7-day accountability streak
  ///
  /// In ar, this message translates to:
  /// **'سبعة أيام من الالتزام والمحاسبة'**
  String get achievementStreak7Desc;

  /// Achievement title: 30-day accountability streak
  ///
  /// In ar, this message translates to:
  /// **'المجاهد المثابر'**
  String get achievementStreak30Title;

  /// Achievement description: 30-day accountability streak
  ///
  /// In ar, this message translates to:
  /// **'ثلاثون يوماً من مراقبة النفس والتقوى'**
  String get achievementStreak30Desc;

  /// Achievement title: read a full juz of Quran in a month
  ///
  /// In ar, this message translates to:
  /// **'أهل القرآن'**
  String get achievementQuranJuzTitle;

  /// Achievement description: read a full juz of Quran in a month
  ///
  /// In ar, this message translates to:
  /// **'ختمت جزءاً كاملاً من كتاب الله'**
  String get achievementQuranJuzDesc;

  /// Achievement title: completed today's self-accountability
  ///
  /// In ar, this message translates to:
  /// **'المحاسب المجتهد'**
  String get achievementDailyMuhasabaTitle;

  /// Achievement description: completed today's self-accountability
  ///
  /// In ar, this message translates to:
  /// **'أكملت محاسبة النفس لهذا اليوم'**
  String get achievementDailyMuhasabaDesc;

  /// Achievement title: completed morning adhkar
  ///
  /// In ar, this message translates to:
  /// **'نور الصباح'**
  String get achievementMorningAdhkarTitle;

  /// Achievement description: completed morning adhkar
  ///
  /// In ar, this message translates to:
  /// **'أكملت أذكار الصباح بالكامل'**
  String get achievementMorningAdhkarDesc;

  /// Achievement title: completed evening adhkar
  ///
  /// In ar, this message translates to:
  /// **'تحصين المساء'**
  String get achievementEveningAdhkarTitle;

  /// Achievement description: completed evening adhkar
  ///
  /// In ar, this message translates to:
  /// **'أكملت أذكار المساء بالكامل'**
  String get achievementEveningAdhkarDesc;

  /// Achievement title: first sadaqah logged through the app
  ///
  /// In ar, this message translates to:
  /// **'اليد المعطية'**
  String get achievementFirstSadaqahTitle;

  /// Achievement description: first sadaqah logged through the app
  ///
  /// In ar, this message translates to:
  /// **'أخرجت أول صدقة لك عبر التطبيق'**
  String get achievementFirstSadaqahDesc;

  /// Achievement title: 100 tasbeeh in one day
  ///
  /// In ar, this message translates to:
  /// **'الذاكر الشاكر'**
  String get achievementTasbeeh100Title;

  /// Achievement description: 100 tasbeeh in one day
  ///
  /// In ar, this message translates to:
  /// **'سبحت الله 100 مرة في يوم واحد'**
  String get achievementTasbeeh100Desc;

  /// Achievement title: Fajr on time for 3 consecutive days
  ///
  /// In ar, this message translates to:
  /// **'في ذمة الله'**
  String get achievementFajrOnTimeTitle;

  /// Achievement description: Fajr on time for 3 consecutive days
  ///
  /// In ar, this message translates to:
  /// **'صليت الفجر في وقته لثلاثة أيام متتالية'**
  String get achievementFajrOnTimeDesc;

  /// Achievement title: read Quran 3 consecutive days
  ///
  /// In ar, this message translates to:
  /// **'القارئ المداوم'**
  String get achievementConstantReaderTitle;

  /// Achievement description: read Quran 3 consecutive days
  ///
  /// In ar, this message translates to:
  /// **'قرأت القرآن لثلاثة أيام متتالية'**
  String get achievementConstantReaderDesc;

  /// Achievement title: all 5 prayers on time for 7 days
  ///
  /// In ar, this message translates to:
  /// **'الصلاة نور'**
  String get achievementPerfectWeekPrayerTitle;

  /// Achievement description: all 5 prayers on time for 7 days
  ///
  /// In ar, this message translates to:
  /// **'أديت جميع الصلوات في وقتها لسبعة أيام'**
  String get achievementPerfectWeekPrayerDesc;

  /// Achievement title: first voluntary (nafl) fast
  ///
  /// In ar, this message translates to:
  /// **'باب الريان'**
  String get achievementFastingNaflTitle;

  /// Achievement description: first voluntary (nafl) fast
  ///
  /// In ar, this message translates to:
  /// **'أكملت صيام النفل الأول لك'**
  String get achievementFastingNaflDesc;

  /// Achievement title: 10 days of Ramadan fasting logged
  ///
  /// In ar, this message translates to:
  /// **'فارس رمضان'**
  String get achievementRamadanKnightTitle;

  /// Achievement description: 10 days of Ramadan fasting logged
  ///
  /// In ar, this message translates to:
  /// **'أكملت 10 أيام من رمضان في المحاسبة'**
  String get achievementRamadanKnightDesc;

  /// Achievement title: reached 100 lifetime Taqwa points
  ///
  /// In ar, this message translates to:
  /// **'مئة خطوة'**
  String get achievementPoints100Title;

  /// Achievement description: reached 100 lifetime Taqwa points
  ///
  /// In ar, this message translates to:
  /// **'جمعت أول 100 نقطة تقوى'**
  String get achievementPoints100Desc;

  /// Achievement title: reached 1000 lifetime Taqwa points
  ///
  /// In ar, this message translates to:
  /// **'فارس التقوى'**
  String get achievementPoints1000Title;

  /// Achievement description: reached 1000 lifetime Taqwa points
  ///
  /// In ar, this message translates to:
  /// **'بلغت 1000 نقطة في مسيرتك'**
  String get achievementPoints1000Desc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
