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

  /// No description provided for @prayerFajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get prayerFajr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In ar, this message translates to:
  /// **'الظهر'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get prayerIsha;

  /// Short chip label: prayer performed on time
  ///
  /// In ar, this message translates to:
  /// **'في وقتها ✓'**
  String get prayerStatusOnTimeShort;

  /// Short chip label: prayer made up late
  ///
  /// In ar, this message translates to:
  /// **'قضاء'**
  String get prayerStatusQadaaShort;

  /// Short chip label: prayer missed
  ///
  /// In ar, this message translates to:
  /// **'فاتت'**
  String get prayerStatusMissedShort;

  /// Short chip label: prayer time has come but not yet marked
  ///
  /// In ar, this message translates to:
  /// **'لم تُؤدَّ بعد'**
  String get prayerStatusPendingShort;

  /// Short chip label: prayer time hasn't come yet
  ///
  /// In ar, this message translates to:
  /// **'لم يحن وقتها'**
  String get prayerStatusNotDueShort;

  /// Status picker option: prayer performed on time
  ///
  /// In ar, this message translates to:
  /// **'أُديت في وقتها'**
  String get prayerStatusPerformedFull;

  /// Status picker option: prayer made up late
  ///
  /// In ar, this message translates to:
  /// **'قُضيت خارج الوقت'**
  String get prayerStatusQadaaFull;

  /// Status picker option: prayer missed
  ///
  /// In ar, this message translates to:
  /// **'فاتت (استغفر الله)'**
  String get prayerStatusMissedFull;

  /// No description provided for @ibadahMorningAdhkarLabel.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get ibadahMorningAdhkarLabel;

  /// No description provided for @ibadahMorningAdhkarSublabel.
  ///
  /// In ar, this message translates to:
  /// **'بعد صلاة الفجر'**
  String get ibadahMorningAdhkarSublabel;

  /// No description provided for @ibadahEveningAdhkarLabel.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get ibadahEveningAdhkarLabel;

  /// No description provided for @ibadahEveningAdhkarSublabel.
  ///
  /// In ar, this message translates to:
  /// **'بعد صلاة العصر'**
  String get ibadahEveningAdhkarSublabel;

  /// No description provided for @ibadahQiyamLabel.
  ///
  /// In ar, this message translates to:
  /// **'قيام الليل'**
  String get ibadahQiyamLabel;

  /// No description provided for @ibadahQiyamSublabel.
  ///
  /// In ar, this message translates to:
  /// **'الثلث الأخير من الليل'**
  String get ibadahQiyamSublabel;

  /// No description provided for @ibadahSadaqahLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصدقة'**
  String get ibadahSadaqahLabel;

  /// No description provided for @ibadahSadaqahSublabel.
  ///
  /// In ar, this message translates to:
  /// **'ولو بكلمة طيبة'**
  String get ibadahSadaqahSublabel;

  /// No description provided for @ibadahGhadhBasarLabel.
  ///
  /// In ar, this message translates to:
  /// **'غضّ البصر'**
  String get ibadahGhadhBasarLabel;

  /// No description provided for @ibadahGhadhBasarSublabel.
  ///
  /// In ar, this message translates to:
  /// **'حفظ النظر عن الحرام'**
  String get ibadahGhadhBasarSublabel;

  /// No description provided for @prohibitionGheebaName.
  ///
  /// In ar, this message translates to:
  /// **'الغيبة'**
  String get prohibitionGheebaName;

  /// No description provided for @prohibitionGheebaDesc.
  ///
  /// In ar, this message translates to:
  /// **'ذكر الناس بما يكرهون'**
  String get prohibitionGheebaDesc;

  /// No description provided for @prohibitionNameemaName.
  ///
  /// In ar, this message translates to:
  /// **'النميمة'**
  String get prohibitionNameemaName;

  /// No description provided for @prohibitionNameemaDesc.
  ///
  /// In ar, this message translates to:
  /// **'نقل الكلام بقصد الإفساد'**
  String get prohibitionNameemaDesc;

  /// No description provided for @prohibitionKadhbName.
  ///
  /// In ar, this message translates to:
  /// **'الكذب'**
  String get prohibitionKadhbName;

  /// No description provided for @prohibitionKadhbDesc.
  ///
  /// In ar, this message translates to:
  /// **'قول غير الحق'**
  String get prohibitionKadhbDesc;

  /// No description provided for @prohibitionGhadabName.
  ///
  /// In ar, this message translates to:
  /// **'الغضب'**
  String get prohibitionGhadabName;

  /// No description provided for @prohibitionGhadabDesc.
  ///
  /// In ar, this message translates to:
  /// **'إن غضبت فاسكت'**
  String get prohibitionGhadabDesc;

  /// No description provided for @prohibitionIdaatWaqtName.
  ///
  /// In ar, this message translates to:
  /// **'إضاعة الوقت'**
  String get prohibitionIdaatWaqtName;

  /// No description provided for @prohibitionIdaatWaqtDesc.
  ///
  /// In ar, this message translates to:
  /// **'التقصير في استثمار الوقت'**
  String get prohibitionIdaatWaqtDesc;

  /// No description provided for @hijriMuharram.
  ///
  /// In ar, this message translates to:
  /// **'محرم'**
  String get hijriMuharram;

  /// No description provided for @hijriSafar.
  ///
  /// In ar, this message translates to:
  /// **'صفر'**
  String get hijriSafar;

  /// No description provided for @hijriRabiAlAwwal.
  ///
  /// In ar, this message translates to:
  /// **'ربيع الأول'**
  String get hijriRabiAlAwwal;

  /// No description provided for @hijriRabiAlThani.
  ///
  /// In ar, this message translates to:
  /// **'ربيع الآخر'**
  String get hijriRabiAlThani;

  /// No description provided for @hijriJumadaAlAwwal.
  ///
  /// In ar, this message translates to:
  /// **'جمادى الأولى'**
  String get hijriJumadaAlAwwal;

  /// No description provided for @hijriJumadaAlThani.
  ///
  /// In ar, this message translates to:
  /// **'جمادى الآخرة'**
  String get hijriJumadaAlThani;

  /// No description provided for @hijriRajab.
  ///
  /// In ar, this message translates to:
  /// **'رجب'**
  String get hijriRajab;

  /// No description provided for @hijriShaban.
  ///
  /// In ar, this message translates to:
  /// **'شعبان'**
  String get hijriShaban;

  /// No description provided for @hijriRamadan.
  ///
  /// In ar, this message translates to:
  /// **'رمضان'**
  String get hijriRamadan;

  /// No description provided for @hijriShawwal.
  ///
  /// In ar, this message translates to:
  /// **'شوال'**
  String get hijriShawwal;

  /// No description provided for @hijriDhulQadah.
  ///
  /// In ar, this message translates to:
  /// **'ذو القعدة'**
  String get hijriDhulQadah;

  /// No description provided for @hijriDhulHijjah.
  ///
  /// In ar, this message translates to:
  /// **'ذو الحجة'**
  String get hijriDhulHijjah;

  /// No description provided for @checklistTitle.
  ///
  /// In ar, this message translates to:
  /// **'محاسبة اليوم'**
  String get checklistTitle;

  /// No description provided for @checklistTodayProgress.
  ///
  /// In ar, this message translates to:
  /// **'إنجاز اليوم'**
  String get checklistTodayProgress;

  /// No description provided for @checklistFivePrayersTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصلوات الخمس'**
  String get checklistFivePrayersTitle;

  /// No description provided for @checklistQuranAdhkarTitle.
  ///
  /// In ar, this message translates to:
  /// **'القرآن والأذكار'**
  String get checklistQuranAdhkarTitle;

  /// No description provided for @checklistProhibitionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحظورات والمهلكات'**
  String get checklistProhibitionsTitle;

  /// No description provided for @checklistProhibitionsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد ما وقعت فيه اليوم بصدق مع نفسك'**
  String get checklistProhibitionsSubtitle;

  /// No description provided for @checklistMotivationComplete.
  ///
  /// In ar, this message translates to:
  /// **'يوم مكتمل الحمد لله ✨'**
  String get checklistMotivationComplete;

  /// No description provided for @checklistMotivationGreat.
  ///
  /// In ar, this message translates to:
  /// **'رائع، أنت على الطريق 💪'**
  String get checklistMotivationGreat;

  /// No description provided for @checklistMotivationKeepGoing.
  ///
  /// In ar, this message translates to:
  /// **'استمر، لا تتوقف 🌿'**
  String get checklistMotivationKeepGoing;

  /// No description provided for @checklistMotivationStart.
  ///
  /// In ar, this message translates to:
  /// **'البداية الآن 🤲'**
  String get checklistMotivationStart;

  /// No description provided for @checklistQuranInputLabel.
  ///
  /// In ar, this message translates to:
  /// **'تلاوة القرآن الكريم'**
  String get checklistQuranInputLabel;

  /// No description provided for @checklistQuranPagesHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عدد الصفحات التي قرأتها'**
  String get checklistQuranPagesHint;

  /// No description provided for @checklistNoteTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة اليوم'**
  String get checklistNoteTitle;

  /// No description provided for @checklistNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظتك أو دعاءك لهذا اليوم...'**
  String get checklistNoteHint;

  /// No description provided for @checklistNoteSaveButton.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الملاحظة'**
  String get checklistNoteSaveButton;

  /// No description provided for @checklistNoteSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ ✓'**
  String get checklistNoteSaved;

  /// Error message prefix, followed by the raw error text
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {error}'**
  String checklistErrorPrefix(String error);

  /// Screen-reader label for the prohibition '+1 count' button
  ///
  /// In ar, this message translates to:
  /// **'زد عدد مرات {name}، حدث {count} مرة'**
  String checklistIncrementSemanticLabel(String name, int count);

  /// Status picker sheet title, e.g. 'Fajr prayer'
  ///
  /// In ar, this message translates to:
  /// **'صلاة {prayerName}'**
  String checklistPrayerSheetTitle(String prayerName);

  /// No description provided for @checklistNetPointsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصافي'**
  String get checklistNetPointsLabel;

  /// No description provided for @checklistPointsSuffix.
  ///
  /// In ar, this message translates to:
  /// **' نقطة'**
  String get checklistPointsSuffix;

  /// No description provided for @checklistFastingLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصيام'**
  String get checklistFastingLabel;

  /// No description provided for @fastingTypeFard.
  ///
  /// In ar, this message translates to:
  /// **'فريضة'**
  String get fastingTypeFard;

  /// No description provided for @fastingTypeNafl.
  ///
  /// In ar, this message translates to:
  /// **'نافلة'**
  String get fastingTypeNafl;

  /// No description provided for @fastingTypeNone.
  ///
  /// In ar, this message translates to:
  /// **'لم أصم'**
  String get fastingTypeNone;

  /// No description provided for @checklistQuranPageSuffix.
  ///
  /// In ar, this message translates to:
  /// **'/صفحة'**
  String get checklistQuranPageSuffix;

  /// Separator joining two clauses in a screen-reader label, e.g. 'name, status'
  ///
  /// In ar, this message translates to:
  /// **'، '**
  String get semanticsSeparator;

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقوى'**
  String get appTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguageLabel;

  /// Language name shown in its own native form, regardless of the app's current UI language
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// Language name shown in its own native form, regardless of the app's current UI language
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsScreenTitle;

  /// No description provided for @settingsAdhanSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الأذان و التنبيهات'**
  String get settingsAdhanSectionTitle;

  /// No description provided for @settingsAdhanNotificationsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأذان والتنبيهات'**
  String get settingsAdhanNotificationsLabel;

  /// No description provided for @settingsAdhanNotificationsSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص الأذان، الوضع الصامت، والتنبيهات'**
  String get settingsAdhanNotificationsSublabel;

  /// No description provided for @settingsWakeBeforeFajrLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاستيقاظ قبل الفجر'**
  String get settingsWakeBeforeFajrLabel;

  /// No description provided for @settingsWakeBeforeFajrSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه بصوت الأذان في الوقت المحدد'**
  String get settingsWakeBeforeFajrSublabel;

  /// No description provided for @settingsWakeTimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وقت الاستيقاظ'**
  String get settingsWakeTimeLabel;

  /// No description provided for @settingsMorningAdhkarLabel.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get settingsMorningAdhkarLabel;

  /// No description provided for @settingsMorningAdhkarSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تذكير يومي الساعة ٦:٣٠ ص'**
  String get settingsMorningAdhkarSublabel;

  /// No description provided for @settingsEveningAdhkarLabel.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get settingsEveningAdhkarLabel;

  /// No description provided for @settingsEveningAdhkarSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تذكير يومي الساعة ٥:٠٠ م'**
  String get settingsEveningAdhkarSublabel;

  /// No description provided for @settingsMuhasabaLabel.
  ///
  /// In ar, this message translates to:
  /// **'محاسبة مسائية'**
  String get settingsMuhasabaLabel;

  /// No description provided for @settingsMuhasabaSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تذكير يومي للمحاسبة'**
  String get settingsMuhasabaSublabel;

  /// No description provided for @settingsDailyDuasLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأدعية اليومية'**
  String get settingsDailyDuasLabel;

  /// No description provided for @settingsDailyDuasSublabel.
  ///
  /// In ar, this message translates to:
  /// **'نفحات من الأدعية النبوية'**
  String get settingsDailyDuasSublabel;

  /// No description provided for @settingsFridaySunnahLabel.
  ///
  /// In ar, this message translates to:
  /// **'سنن الجمعة'**
  String get settingsFridaySunnahLabel;

  /// No description provided for @settingsFridaySunnahSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تذكير بسورة الكهف والجمعة'**
  String get settingsFridaySunnahSublabel;

  /// No description provided for @settingsFastingRemindersLabel.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الصيام'**
  String get settingsFastingRemindersLabel;

  /// No description provided for @settingsFastingRemindersSublabel.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين والخميس والأيام البيض'**
  String get settingsFastingRemindersSublabel;

  /// No description provided for @settingsMuhasabaTimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وقت المحاسبة'**
  String get settingsMuhasabaTimeLabel;

  /// No description provided for @settingsAppearanceSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsAppearanceSectionTitle;

  /// No description provided for @settingsThemeModeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وضع المظهر'**
  String get settingsThemeModeLabel;

  /// No description provided for @themeModeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (حسب النظام)'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get themeModeDark;

  /// No description provided for @settingsRamadanSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'وضع رمضان'**
  String get settingsRamadanSectionTitle;

  /// No description provided for @settingsRamadanModeSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل المميزات الرمضانية'**
  String get settingsRamadanModeSublabel;

  /// No description provided for @settingsAppSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق'**
  String get settingsAppSectionTitle;

  /// No description provided for @settingsTestNotifLabel.
  ///
  /// In ar, this message translates to:
  /// **'اختبار الإشعارات والنافذة'**
  String get settingsTestNotifLabel;

  /// No description provided for @settingsTestNotifSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من عمل الإشعارات والنوافذ العائمة'**
  String get settingsTestNotifSublabel;

  /// No description provided for @settingsSubscriptionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك'**
  String get settingsSubscriptionLabel;

  /// No description provided for @settingsSubscriptionSublabel.
  ///
  /// In ar, this message translates to:
  /// **'دعم المشروع والاستمرار'**
  String get settingsSubscriptionSublabel;

  /// No description provided for @settingsAboutDevLabel.
  ///
  /// In ar, this message translates to:
  /// **'عن المطور'**
  String get settingsAboutDevLabel;

  /// No description provided for @settingsAboutDevSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تعرف على مبرمج التطبيق'**
  String get settingsAboutDevSublabel;

  /// No description provided for @settingsTermsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والخصوصية'**
  String get settingsTermsLabel;

  /// No description provided for @settingsTermsSublabel.
  ///
  /// In ar, this message translates to:
  /// **'شروط الدخول والخصوصية'**
  String get settingsTermsSublabel;

  /// No description provided for @settingsLogoutLabel.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get settingsLogoutLabel;

  /// No description provided for @settingsLogoutSublabel.
  ///
  /// In ar, this message translates to:
  /// **'الخروج من الحساب أو وضع الزائر'**
  String get settingsLogoutSublabel;

  /// No description provided for @settingsBismillah.
  ///
  /// In ar, this message translates to:
  /// **'بسم الله الرحمن الرحيم'**
  String get settingsBismillah;

  /// No description provided for @settingsAppVersionLabel.
  ///
  /// In ar, this message translates to:
  /// **'تقوى — v1.0.0'**
  String get settingsAppVersionLabel;

  /// No description provided for @settingsTestNotifSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختبار الإشعارات'**
  String get settingsTestNotifSheetTitle;

  /// No description provided for @settingsTestNotifPlainLabel.
  ///
  /// In ar, this message translates to:
  /// **'إشعار عادي'**
  String get settingsTestNotifPlainLabel;

  /// No description provided for @settingsTestNotifPlainSublabel.
  ///
  /// In ar, this message translates to:
  /// **'إشعار النظام التقليدي'**
  String get settingsTestNotifPlainSublabel;

  /// No description provided for @settingsTestAdhanLabel.
  ///
  /// In ar, this message translates to:
  /// **'أذان الصلاة'**
  String get settingsTestAdhanLabel;

  /// No description provided for @settingsTestAdhanSublabel.
  ///
  /// In ar, this message translates to:
  /// **'شاشة الأذان الكاملة مع الصوت'**
  String get settingsTestAdhanSublabel;

  /// No description provided for @settingsResetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الضبط'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف جميع الإعدادات؟'**
  String get settingsResetConfirm;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في تسجيل الخروج؟'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsLogoutConfirmButton.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get settingsLogoutConfirmButton;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @settingsTestNotifTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختبار الإشعار'**
  String get settingsTestNotifTitle;

  /// No description provided for @settingsTestNotifBody.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات تعمل بشكل صحيح'**
  String get settingsTestNotifBody;

  /// No description provided for @prayerSunrise.
  ///
  /// In ar, this message translates to:
  /// **'الشروق'**
  String get prayerSunrise;

  /// No description provided for @labelQuran.
  ///
  /// In ar, this message translates to:
  /// **'القرآن'**
  String get labelQuran;

  /// No description provided for @labelAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get labelAdhkar;

  /// No description provided for @labelPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقطة'**
  String get labelPoints;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير 🌅'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير 🌤'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء النور 🌙'**
  String get homeGreetingEvening;

  /// No description provided for @homeRamadanBannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمضان كريم'**
  String get homeRamadanBannerTitle;

  /// No description provided for @homeRamadanBannerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اليوم {day} من شهر رمضان المبارك'**
  String homeRamadanBannerSubtitle(int day);

  /// No description provided for @homeRamadanDaysRemaining.
  ///
  /// In ar, this message translates to:
  /// **'يوم\nمتبقي'**
  String get homeRamadanDaysRemaining;

  /// No description provided for @homeCountdownNow.
  ///
  /// In ar, this message translates to:
  /// **'حان الوقت الآن'**
  String get homeCountdownNow;

  /// No description provided for @homeCountdownHoursMinutes.
  ///
  /// In ar, this message translates to:
  /// **'بعد {hours}س {minutes}د'**
  String homeCountdownHoursMinutes(int hours, int minutes);

  /// No description provided for @homeCountdownMinutesOnly.
  ///
  /// In ar, this message translates to:
  /// **'بعد {minutes} دقيقة'**
  String homeCountdownMinutesOnly(int minutes);

  /// No description provided for @homeNextPrayerLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get homeNextPrayerLabel;

  /// No description provided for @homePrayerTimesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أوقات الصلاة'**
  String get homePrayerTimesTitle;

  /// No description provided for @homeTodayIbadahTitle.
  ///
  /// In ar, this message translates to:
  /// **'عبادات اليوم'**
  String get homeTodayIbadahTitle;

  /// No description provided for @homeViewAllLabel.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل ←'**
  String get homeViewAllLabel;

  /// No description provided for @homeIbadahProgressLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} من ١٠ عبادات'**
  String homeIbadahProgressLabel(int count);

  /// No description provided for @homeStreakDaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'{n} يوم متواصل'**
  String homeStreakDaysLabel(int n);

  /// No description provided for @homeLevelMubtadi.
  ///
  /// In ar, this message translates to:
  /// **'مبتدئ 🌱'**
  String get homeLevelMubtadi;

  /// No description provided for @homeLevelSalik.
  ///
  /// In ar, this message translates to:
  /// **'سالك 🌿'**
  String get homeLevelSalik;

  /// No description provided for @homeLevelMujahid.
  ///
  /// In ar, this message translates to:
  /// **'مجاهد ⚔️'**
  String get homeLevelMujahid;

  /// No description provided for @homeLevelMutaqi.
  ///
  /// In ar, this message translates to:
  /// **'متقي ✨'**
  String get homeLevelMutaqi;

  /// No description provided for @homeProgressMsgComplete.
  ///
  /// In ar, this message translates to:
  /// **'ما شاء الله! 🌟'**
  String get homeProgressMsgComplete;

  /// No description provided for @homeProgressMsgGreat.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت، استمر 💪'**
  String get homeProgressMsgGreat;

  /// No description provided for @homeProgressMsgGood.
  ///
  /// In ar, this message translates to:
  /// **'بداية جيدة 🌿'**
  String get homeProgressMsgGood;

  /// No description provided for @homeProgressMsgStart.
  ///
  /// In ar, this message translates to:
  /// **'بسم الله 🤲'**
  String get homeProgressMsgStart;

  /// No description provided for @homeRingTodayLabel.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get homeRingTodayLabel;

  /// No description provided for @homeFeaturesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الميزات'**
  String get homeFeaturesTitle;

  /// No description provided for @homeFeaturePrayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'أوقات\nالصلاة'**
  String get homeFeaturePrayerTimes;

  /// No description provided for @homeFeatureQibla.
  ///
  /// In ar, this message translates to:
  /// **'القبلة'**
  String get homeFeatureQibla;

  /// No description provided for @homeFeatureDuas.
  ///
  /// In ar, this message translates to:
  /// **'الأدعية'**
  String get homeFeatureDuas;

  /// No description provided for @homeFeatureMisbaha.
  ///
  /// In ar, this message translates to:
  /// **'المسبحة'**
  String get homeFeatureMisbaha;

  /// No description provided for @homeFeatureMosques.
  ///
  /// In ar, this message translates to:
  /// **'المساجد'**
  String get homeFeatureMosques;

  /// No description provided for @homeFeatureStatistics.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات'**
  String get homeFeatureStatistics;

  /// No description provided for @homeFeatureAchievements.
  ///
  /// In ar, this message translates to:
  /// **'الإنجازات'**
  String get homeFeatureAchievements;

  /// No description provided for @homeFeatureReminders.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get homeFeatureReminders;

  /// Prefix label before a Quranic verse reference; the reference itself stays untranslated Arabic content
  ///
  /// In ar, this message translates to:
  /// **'آية اليوم - {reference}'**
  String homeVerseOfDayLabel(String reference);

  /// No description provided for @homeRamadanTimesTitle.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت رمضان'**
  String get homeRamadanTimesTitle;

  /// No description provided for @homeIftarLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإفطار'**
  String get homeIftarLabel;

  /// No description provided for @homeSuhoorLabel.
  ///
  /// In ar, this message translates to:
  /// **'السحور'**
  String get homeSuhoorLabel;

  /// No description provided for @homeCountdownPassed.
  ///
  /// In ar, this message translates to:
  /// **'مضى ✓'**
  String get homeCountdownPassed;

  /// No description provided for @homeDailyDhikrLabel.
  ///
  /// In ar, this message translates to:
  /// **'ذكر اليوم'**
  String get homeDailyDhikrLabel;

  /// No description provided for @homeBooksLibraryTitle.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة الإسلامية'**
  String get homeBooksLibraryTitle;

  /// No description provided for @homeMinutesLabel.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String homeMinutesLabel(int minutes);

  /// No description provided for @onboardingGpsDisabledMessage.
  ///
  /// In ar, this message translates to:
  /// **'GPS غير مفعّل، يرجى تفعيله للمتابعة.'**
  String get onboardingGpsDisabledMessage;

  /// No description provided for @onboardingSettingsAction.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات'**
  String get onboardingSettingsAction;

  /// No description provided for @onboardingLocationPermissionDeniedMessage.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تفعيل إذن الموقع من الإعدادات.'**
  String get onboardingLocationPermissionDeniedMessage;

  /// No description provided for @onboardingEditLaterHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك التعديل لاحقًا'**
  String get onboardingEditLaterHint;

  /// No description provided for @onboardingContinueButton.
  ///
  /// In ar, this message translates to:
  /// **'استمرار'**
  String get onboardingContinueButton;

  /// No description provided for @onboardingIntro1Title.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في تقوى'**
  String get onboardingIntro1Title;

  /// No description provided for @onboardingIntro1Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'رفيقك في رحلة التزكية والقرب من الله عز وجل، من خلال أدوات ذكية ومميزة.'**
  String get onboardingIntro1Subtitle;

  /// No description provided for @onboardingIntro2Title.
  ///
  /// In ar, this message translates to:
  /// **'نظام المحاسبة الدقيق'**
  String get onboardingIntro2Title;

  /// No description provided for @onboardingIntro2Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل صلواتك، أذكارك، وطاعاتك يومياً لترى تطورك وتثبّت عزيمتك.'**
  String get onboardingIntro2Subtitle;

  /// No description provided for @onboardingIntro3Title.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات وتقدم'**
  String get onboardingIntro3Title;

  /// No description provided for @onboardingIntro3Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'تابِع نتائج محاسبتك عبر رسوم بيانية وتقارير مفصلة تعينك على الثبات.'**
  String get onboardingIntro3Subtitle;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج لموقعك لنحدد لك أوقات الصلاة واتجاه القبلة بدقة متناهية'**
  String get onboardingLocationSubtitle;

  /// No description provided for @onboardingLocationHint.
  ///
  /// In ar, this message translates to:
  /// **'بيانات موقعك تبقى في جهازك ولا نطلع عليها أبداً'**
  String get onboardingLocationHint;

  /// No description provided for @onboardingLocationAllowButton.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الموقع 📍'**
  String get onboardingLocationAllowButton;

  /// No description provided for @onboardingSkipButton.
  ///
  /// In ar, this message translates to:
  /// **'تخطى'**
  String get onboardingSkipButton;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'السماح بإرسال التنبيهات'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يمكننا من تذكيرك بالصلاة والأذكار والمحاسبة المسائية والمزيد'**
  String get onboardingNotificationsSubtitle;

  /// No description provided for @onboardingNotificationsHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تغيير هذا لاحقًا من الإعدادات'**
  String get onboardingNotificationsHint;

  /// No description provided for @onboardingNotificationsAllowButton.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالتنبيهات 🔔'**
  String get onboardingNotificationsAllowButton;

  /// No description provided for @onboardingGenderTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد الجنس'**
  String get onboardingGenderTitle;

  /// No description provided for @onboardingGenderMale.
  ///
  /// In ar, this message translates to:
  /// **'مسلم'**
  String get onboardingGenderMale;

  /// No description provided for @onboardingGenderFemale.
  ///
  /// In ar, this message translates to:
  /// **'مسلمة'**
  String get onboardingGenderFemale;

  /// No description provided for @onboardingGenderInfoHint.
  ///
  /// In ar, this message translates to:
  /// **'تجربة استخدام مناسبة، وختمات عامة للرجال وأخرى للنساء'**
  String get onboardingGenderInfoHint;

  /// No description provided for @onboardingNextButton.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get onboardingNextButton;

  /// No description provided for @onboardingOverlayTitle.
  ///
  /// In ar, this message translates to:
  /// **'نافذة الأذكار 🪟'**
  String get onboardingOverlayTitle;

  /// No description provided for @onboardingOverlaySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تسمح بعرض الأذكار والتنبيهات فوق التطبيقات الأخرى لتذكيرك الدائم'**
  String get onboardingOverlaySubtitle;

  /// No description provided for @onboardingOverlayHint.
  ///
  /// In ar, this message translates to:
  /// **'يتطلب إذن \"الظهور فوق التطبيقات\" على أندرويد'**
  String get onboardingOverlayHint;

  /// No description provided for @onboardingOverlayAllowButton.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل النافذة'**
  String get onboardingOverlayAllowButton;

  /// No description provided for @onboardingBackgroundTitle.
  ///
  /// In ar, this message translates to:
  /// **'التشغيل في الخلفية'**
  String get onboardingBackgroundTitle;

  /// No description provided for @onboardingBackgroundSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لضمان وصول تنبيهات الأذان والأذكار في وقتها بدقة دون توقف التطبيق'**
  String get onboardingBackgroundSubtitle;

  /// No description provided for @onboardingBackgroundHint.
  ///
  /// In ar, this message translates to:
  /// **'يطلب النظام استثناء التطبيق من تحسين البطارية'**
  String get onboardingBackgroundHint;

  /// No description provided for @onboardingBackgroundAllowButton.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالتشغيل 🔋'**
  String get onboardingBackgroundAllowButton;

  /// No description provided for @statsPeriodLast7Days.
  ///
  /// In ar, this message translates to:
  /// **'آخر ٧ أيام'**
  String get statsPeriodLast7Days;

  /// No description provided for @statsPeriodThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get statsPeriodThisMonth;

  /// No description provided for @statsPeriodRamadan.
  ///
  /// In ar, this message translates to:
  /// **'رمضان'**
  String get statsPeriodRamadan;

  /// No description provided for @statsPeriodThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get statsPeriodThisWeek;

  /// No description provided for @statsPeriodRamadanEmoji.
  ///
  /// In ar, this message translates to:
  /// **'رمضان 🌙'**
  String get statsPeriodRamadanEmoji;

  /// No description provided for @statsRamadanReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير رمضان 🌙'**
  String get statsRamadanReportTitle;

  /// No description provided for @statsScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get statsScreenTitle;

  /// No description provided for @statsRamadanDayOf30.
  ///
  /// In ar, this message translates to:
  /// **'يوم {day} من ٣٠'**
  String statsRamadanDayOf30(int day);

  /// No description provided for @statsPointsThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'{points} نقطة هذا الشهر'**
  String statsPointsThisMonth(int points);

  /// No description provided for @statsNextLevelLabel.
  ///
  /// In ar, this message translates to:
  /// **'المستوى التالي'**
  String get statsNextLevelLabel;

  /// No description provided for @statsPointsRemaining.
  ///
  /// In ar, this message translates to:
  /// **'{remaining} نقطة متبقية'**
  String statsPointsRemaining(int remaining);

  /// No description provided for @statsMaxLevelReached.
  ///
  /// In ar, this message translates to:
  /// **'أقصى مستوى ✨'**
  String get statsMaxLevelReached;

  /// No description provided for @statsPerformanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'أداء الفترة'**
  String get statsPerformanceTitle;

  /// No description provided for @statsPreviousDaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'أيام سابقة'**
  String get statsPreviousDaysLabel;

  /// No description provided for @statsQuranPagesLabel.
  ///
  /// In ar, this message translates to:
  /// **'صفحات القرآن'**
  String get statsQuranPagesLabel;

  /// No description provided for @statsPrayerAttendanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'حضور الصلوات'**
  String get statsPrayerAttendanceLabel;

  /// No description provided for @statsLongestStreakLabel.
  ///
  /// In ar, this message translates to:
  /// **'أطول سلسلة'**
  String get statsLongestStreakLabel;

  /// No description provided for @statsDaysUnit.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String statsDaysUnit(int count);

  /// No description provided for @statsTaqwaPointsLabel.
  ///
  /// In ar, this message translates to:
  /// **'نقاط التقوى'**
  String get statsTaqwaPointsLabel;

  /// No description provided for @statsAchievementsSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإنجازات والشارات'**
  String get statsAchievementsSectionTitle;

  /// No description provided for @statsAchievementsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} إنجاز'**
  String statsAchievementsCount(int count);

  /// No description provided for @statsPointsRewardShort.
  ///
  /// In ar, this message translates to:
  /// **'+{points} نقطة'**
  String statsPointsRewardShort(int points);

  /// No description provided for @statsNoAchievementsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا إنجازات بعد'**
  String get statsNoAchievementsYet;

  /// No description provided for @statsNoAchievementsHint.
  ///
  /// In ar, this message translates to:
  /// **'حافظ على العبادات لتحصل على أول إنجاز'**
  String get statsNoAchievementsHint;

  /// No description provided for @statsComingSoonLabel.
  ///
  /// In ar, this message translates to:
  /// **'قادم قريباً 🔒'**
  String get statsComingSoonLabel;

  /// No description provided for @statsLockedStreak30Title.
  ///
  /// In ar, this message translates to:
  /// **'شهر المجاهد'**
  String get statsLockedStreak30Title;

  /// No description provided for @statsLockedStreak30Desc.
  ///
  /// In ar, this message translates to:
  /// **'٣٠ يوم متواصل'**
  String get statsLockedStreak30Desc;

  /// No description provided for @statsLockedKhatmaTitle.
  ///
  /// In ar, this message translates to:
  /// **'ختمة كاملة'**
  String get statsLockedKhatmaTitle;

  /// No description provided for @statsLockedKhatmaDesc.
  ///
  /// In ar, this message translates to:
  /// **'إتمام القرآن'**
  String get statsLockedKhatmaDesc;

  /// No description provided for @statsLockedFullWeekTitle.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع مثالي'**
  String get statsLockedFullWeekTitle;

  /// No description provided for @statsLockedFullWeekDesc.
  ///
  /// In ar, this message translates to:
  /// **'٧ أيام مكتملة'**
  String get statsLockedFullWeekDesc;

  /// No description provided for @statsThanksButtonLabel.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لله 🤲'**
  String get statsThanksButtonLabel;

  /// No description provided for @statsPointsRewardFull.
  ///
  /// In ar, this message translates to:
  /// **'+{points} نقطة مكافأة 🌟'**
  String statsPointsRewardFull(int points);

  /// No description provided for @statsNewAchievementLabel.
  ///
  /// In ar, this message translates to:
  /// **'إنجاز جديد! 🎉'**
  String get statsNewAchievementLabel;

  /// No description provided for @drawerLevelLabel.
  ///
  /// In ar, this message translates to:
  /// **'المستوى: {level}'**
  String drawerLevelLabel(String level);

  /// Fallback username shown in the drawer when the user has no username set
  ///
  /// In ar, this message translates to:
  /// **'مستخدم تقوى'**
  String get drawerDefaultUsername;

  /// Gender badge label for male users in the drawer header
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get drawerGenderMale;

  /// Gender badge label for female users in the drawer header
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get drawerGenderFemale;

  /// Subtitle link in the drawer header that navigates to the profile screen
  ///
  /// In ar, this message translates to:
  /// **'عرض البروفايل'**
  String get drawerViewProfile;

  /// Drawer navigation item: Home
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get drawerNavHome;

  /// Drawer navigation item: Daily accountability checklist
  ///
  /// In ar, this message translates to:
  /// **'محاسبة اليوم'**
  String get drawerNavChecklist;

  /// Drawer navigation item: Prayer times
  ///
  /// In ar, this message translates to:
  /// **'أوقات الصلاة'**
  String get drawerNavPrayer;

  /// Drawer navigation item: Islamic library
  ///
  /// In ar, this message translates to:
  /// **'المكتبة الإسلامية'**
  String get drawerNavBooks;

  /// Drawer navigation item: Statistics
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get drawerNavStatistics;

  /// Drawer navigation item: Achievements
  ///
  /// In ar, this message translates to:
  /// **'الإنجازات'**
  String get drawerNavAchievements;

  /// Drawer navigation item: User profile
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get drawerNavProfile;

  /// Drawer navigation item: Settings
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get drawerNavSettings;

  /// Label under the Taqwa points mini-stat card in the drawer
  ///
  /// In ar, this message translates to:
  /// **'نقطة التقوى'**
  String get drawerStatTaqwaPoints;

  /// Label under the consecutive-days streak mini-stat card in the drawer
  ///
  /// In ar, this message translates to:
  /// **'يوم متواصل'**
  String get drawerStatStreakDays;

  /// Label on the logout button at the bottom of the drawer
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get drawerLogoutButton;

  /// Title of the logout confirmation dialog
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get drawerLogoutDialogTitle;

  /// Body text of the logout confirmation dialog
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في تسجيل الخروج؟'**
  String get drawerLogoutDialogBody;

  /// Cancel button in the logout confirmation dialog
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get drawerLogoutDialogCancel;

  /// Confirm button in the logout confirmation dialog
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get drawerLogoutDialogConfirm;

  /// Islamic quote shown in the drawer footer
  ///
  /// In ar, this message translates to:
  /// **'\"حَاسِبُوا أَنفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا\"'**
  String get drawerFooterQuote;

  /// App version label shown in the drawer footer
  ///
  /// In ar, this message translates to:
  /// **' v1.0'**
  String get drawerFooterVersion;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @duaCategoryMorning.
  ///
  /// In ar, this message translates to:
  /// **'الصباح'**
  String get duaCategoryMorning;

  /// No description provided for @duaCategoryEvening.
  ///
  /// In ar, this message translates to:
  /// **'المساء'**
  String get duaCategoryEvening;

  /// No description provided for @duaCategorySleep.
  ///
  /// In ar, this message translates to:
  /// **'النوم'**
  String get duaCategorySleep;

  /// No description provided for @duaCategoryWakingUp.
  ///
  /// In ar, this message translates to:
  /// **'الاستيقاظ'**
  String get duaCategoryWakingUp;

  /// No description provided for @duaCategoryDistress.
  ///
  /// In ar, this message translates to:
  /// **'الكرب'**
  String get duaCategoryDistress;

  /// No description provided for @duaCategoryGuidance.
  ///
  /// In ar, this message translates to:
  /// **'الهداية'**
  String get duaCategoryGuidance;

  /// No description provided for @duaCategoryForgiveness.
  ///
  /// In ar, this message translates to:
  /// **'المغفرة'**
  String get duaCategoryForgiveness;

  /// No description provided for @duaCategoryRizq.
  ///
  /// In ar, this message translates to:
  /// **'الرزق'**
  String get duaCategoryRizq;

  /// No description provided for @duaCategoryHealth.
  ///
  /// In ar, this message translates to:
  /// **'الصحة'**
  String get duaCategoryHealth;

  /// No description provided for @duaCategoryParents.
  ///
  /// In ar, this message translates to:
  /// **'الوالدين'**
  String get duaCategoryParents;

  /// No description provided for @duaCategoryTravel.
  ///
  /// In ar, this message translates to:
  /// **'السفر'**
  String get duaCategoryTravel;

  /// No description provided for @duaCategoryRain.
  ///
  /// In ar, this message translates to:
  /// **'الاستسقاء'**
  String get duaCategoryRain;

  /// No description provided for @duaCategoryIstikhara.
  ///
  /// In ar, this message translates to:
  /// **'الاستخارة'**
  String get duaCategoryIstikhara;

  /// No description provided for @duaCategoryMosque.
  ///
  /// In ar, this message translates to:
  /// **'المسجد'**
  String get duaCategoryMosque;

  /// No description provided for @duaCategoryKnowledge.
  ///
  /// In ar, this message translates to:
  /// **'طلب العلم'**
  String get duaCategoryKnowledge;

  /// No description provided for @duaCategoryAfterPrayer.
  ///
  /// In ar, this message translates to:
  /// **'بعد الصلاة'**
  String get duaCategoryAfterPrayer;

  /// No description provided for @duaCategoryGeneral.
  ///
  /// In ar, this message translates to:
  /// **'عامة'**
  String get duaCategoryGeneral;

  /// No description provided for @duaCategoryOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get duaCategoryOther;

  /// No description provided for @duaCategoryAllFilter.
  ///
  /// In ar, this message translates to:
  /// **'🤲 الكل'**
  String get duaCategoryAllFilter;

  /// No description provided for @duasScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأدعية المأثورة'**
  String get duasScreenTitle;

  /// No description provided for @duasScreenSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'من الكتاب والسنة'**
  String get duasScreenSubtitle;

  /// No description provided for @duasSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الأدعية...'**
  String get duasSearchHint;

  /// No description provided for @duasTabTraditional.
  ///
  /// In ar, this message translates to:
  /// **'المأثورة'**
  String get duasTabTraditional;

  /// No description provided for @duasTabMine.
  ///
  /// In ar, this message translates to:
  /// **'أدعيتي'**
  String get duasTabMine;

  /// No description provided for @duasTabCommunity.
  ///
  /// In ar, this message translates to:
  /// **'من المجتمع'**
  String get duasTabCommunity;

  /// No description provided for @duasNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get duasNoResults;

  /// No description provided for @duasCopiedLabel.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ ✓'**
  String get duasCopiedLabel;

  /// No description provided for @duasCopyTooltip.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get duasCopyTooltip;

  /// No description provided for @duasFetchErrorMessage.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في جلب أدعيتك'**
  String get duasFetchErrorMessage;

  /// No description provided for @duasNoUserDuasYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تقم بإضافة أي أدعية بعد'**
  String get duasNoUserDuasYet;

  /// No description provided for @duasShareWithCommunityLabel.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة مع المجتمع'**
  String get duasShareWithCommunityLabel;

  /// No description provided for @duasDeleteDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الدعاء'**
  String get duasDeleteDialogTitle;

  /// No description provided for @duasDeleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا الدعاء؟'**
  String get duasDeleteConfirmMessage;

  /// No description provided for @duasSharedSuccessLabel.
  ///
  /// In ar, this message translates to:
  /// **'✅ تمت المشاركة!'**
  String get duasSharedSuccessLabel;

  /// No description provided for @duasShareSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'🌍 مشاركة مع المجتمع'**
  String get duasShareSheetTitle;

  /// No description provided for @duasShareThanksMessage.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لمشاركتك مع مجتمع تقوى 🤍'**
  String get duasShareThanksMessage;

  /// No description provided for @duasCommunityLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل أدعية المجتمع'**
  String get duasCommunityLoadError;

  /// No description provided for @duasCommunityEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أدعية مشتركة حالياً'**
  String get duasCommunityEmptyTitle;

  /// No description provided for @duasPullToRefreshHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب للأسفل للتحديث'**
  String get duasPullToRefreshHint;

  /// No description provided for @duasAddSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دعاء'**
  String get duasAddSheetTitle;

  /// No description provided for @duasAddTitleFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الدعاء'**
  String get duasAddTitleFieldLabel;

  /// No description provided for @duasAddTextFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'نص الدعاء (عربي)'**
  String get duasAddTextFieldLabel;

  /// No description provided for @duasAddOccasionFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'المناسبة (اختياري)'**
  String get duasAddOccasionFieldLabel;

  /// No description provided for @duasAddShareToggleLabel.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة مع مجتمع تقوى (ليستفيد منه الآخرون)'**
  String get duasAddShareToggleLabel;

  /// No description provided for @adhanSoundMakkah.
  ///
  /// In ar, this message translates to:
  /// **'أذان مكة المكرمة'**
  String get adhanSoundMakkah;

  /// No description provided for @adhanSoundMadinah.
  ///
  /// In ar, this message translates to:
  /// **'أذان المدينة المنورة'**
  String get adhanSoundMadinah;

  /// No description provided for @adhanSoundAlaqsa.
  ///
  /// In ar, this message translates to:
  /// **'أذان المسجد الأقصى'**
  String get adhanSoundAlaqsa;

  /// No description provided for @adhanSoundEgypt.
  ///
  /// In ar, this message translates to:
  /// **'الأذان المصري'**
  String get adhanSoundEgypt;

  /// No description provided for @adhanSoundAbdulBasit.
  ///
  /// In ar, this message translates to:
  /// **'عبد الباسط عبد الصمد'**
  String get adhanSoundAbdulBasit;

  /// No description provided for @adhanSoundMinshawi.
  ///
  /// In ar, this message translates to:
  /// **'محمد صديق المنشاوي'**
  String get adhanSoundMinshawi;

  /// No description provided for @adhanSoundNaghshbandi.
  ///
  /// In ar, this message translates to:
  /// **'سيد النقشبندي'**
  String get adhanSoundNaghshbandi;

  /// No description provided for @adhanSoundSaber.
  ///
  /// In ar, this message translates to:
  /// **'جامع صابر'**
  String get adhanSoundSaber;

  /// No description provided for @adhanSoundAlHussaini.
  ///
  /// In ar, this message translates to:
  /// **'الحسيني'**
  String get adhanSoundAlHussaini;

  /// No description provided for @adhanSoundBakirBash.
  ///
  /// In ar, this message translates to:
  /// **'بكير باش'**
  String get adhanSoundBakirBash;

  /// No description provided for @adhanSoundHafez.
  ///
  /// In ar, this message translates to:
  /// **'حافظ'**
  String get adhanSoundHafez;

  /// No description provided for @adhanSoundHafizMurad.
  ///
  /// In ar, this message translates to:
  /// **'حافظ مراد'**
  String get adhanSoundHafizMurad;

  /// No description provided for @adhanSoundSharifDoman.
  ///
  /// In ar, this message translates to:
  /// **'شريف دومان'**
  String get adhanSoundSharifDoman;

  /// No description provided for @adhanSoundYusufIslam.
  ///
  /// In ar, this message translates to:
  /// **'يوسف إسلام'**
  String get adhanSoundYusufIslam;

  /// No description provided for @adhanSettingsAccountSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get adhanSettingsAccountSectionTitle;

  /// No description provided for @adhanMadhabLabel.
  ///
  /// In ar, this message translates to:
  /// **'المذهب'**
  String get adhanMadhabLabel;

  /// No description provided for @madhabShafi.
  ///
  /// In ar, this message translates to:
  /// **'شافعي، مالكي، حنبلي'**
  String get madhabShafi;

  /// No description provided for @madhabHanafi.
  ///
  /// In ar, this message translates to:
  /// **'حنفي'**
  String get madhabHanafi;

  /// No description provided for @adhanCalcMethodLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الحساب'**
  String get adhanCalcMethodLabel;

  /// No description provided for @calcMethodAlgeria.
  ///
  /// In ar, this message translates to:
  /// **'الجزائر (وزارة الشؤون الدينية)'**
  String get calcMethodAlgeria;

  /// No description provided for @calcMethodMWL.
  ///
  /// In ar, this message translates to:
  /// **'رابطة العالم الإسلامي'**
  String get calcMethodMWL;

  /// No description provided for @calcMethodEgypt.
  ///
  /// In ar, this message translates to:
  /// **'دار الإفتاء المصرية'**
  String get calcMethodEgypt;

  /// No description provided for @calcMethodKarachi.
  ///
  /// In ar, this message translates to:
  /// **'جامعة كراتشي'**
  String get calcMethodKarachi;

  /// No description provided for @calcMethodUmmAlQura.
  ///
  /// In ar, this message translates to:
  /// **'أم القرى (مكة المكرمة)'**
  String get calcMethodUmmAlQura;

  /// No description provided for @calcMethodISNA.
  ///
  /// In ar, this message translates to:
  /// **'أمريكا الشمالية'**
  String get calcMethodISNA;

  /// No description provided for @adhanSoundSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'صوت الأذان'**
  String get adhanSoundSectionTitle;

  /// No description provided for @adhanModeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وضع الأذان'**
  String get adhanModeLabel;

  /// No description provided for @adhanModeSound.
  ///
  /// In ar, this message translates to:
  /// **'صوت'**
  String get adhanModeSound;

  /// No description provided for @adhanModeVibrate.
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز'**
  String get adhanModeVibrate;

  /// No description provided for @adhanModeSilent.
  ///
  /// In ar, this message translates to:
  /// **'صامت'**
  String get adhanModeSilent;

  /// No description provided for @adhanVolumeLabel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الصوت'**
  String get adhanVolumeLabel;

  /// No description provided for @adhanVibrateTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الاهتزاز'**
  String get adhanVibrateTypeLabel;

  /// No description provided for @adhanVibrateTypeSublabel.
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز مصاحب للأذان'**
  String get adhanVibrateTypeSublabel;

  /// No description provided for @adhanAdvancedSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'خصائص متقدمة'**
  String get adhanAdvancedSectionTitle;

  /// No description provided for @adhanAutoSilentLabel.
  ///
  /// In ar, this message translates to:
  /// **'التحويل إلى الصامت'**
  String get adhanAutoSilentLabel;

  /// No description provided for @adhanAutoSilentSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل وضع الصامت بعد الأذان'**
  String get adhanAutoSilentSublabel;

  /// No description provided for @adhanSilentModeSettingsLabel.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الوضع الصامت'**
  String get adhanSilentModeSettingsLabel;

  /// No description provided for @adhanSilentModeSettingsSublabel.
  ///
  /// In ar, this message translates to:
  /// **'إدارة خيارات وضع الصامت'**
  String get adhanSilentModeSettingsSublabel;

  /// No description provided for @adhanEnableInSilentLabel.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الأذان في الوضع الصامت'**
  String get adhanEnableInSilentLabel;

  /// No description provided for @adhanEnableInSilentSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الأذان حتى وإن كان الجهاز في وضع الصامت'**
  String get adhanEnableInSilentSublabel;

  /// No description provided for @adhanEnableNotifInSilentLabel.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل التنبيهات في الوضع الصامت'**
  String get adhanEnableNotifInSilentLabel;

  /// No description provided for @adhanEnableNotifInSilentSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل صوت التنبيهات حتى وإن كان الجهاز في وضع الصامت'**
  String get adhanEnableNotifInSilentSublabel;

  /// No description provided for @adhanNotifSilentSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات المفعلة في الوضع الصامت'**
  String get adhanNotifSilentSheetTitle;

  /// No description provided for @adhanSystemNotifSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات النظام'**
  String get adhanSystemNotifSectionTitle;

  /// No description provided for @adhanWakeScreenLabel.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الشاشة أثناء الأذان'**
  String get adhanWakeScreenLabel;

  /// No description provided for @adhanWakeScreenSublabel.
  ///
  /// In ar, this message translates to:
  /// **'إبقاء الشاشة مفعلة عند تشغيل الأذان'**
  String get adhanWakeScreenSublabel;

  /// No description provided for @adhanFlipToSilenceLabel.
  ///
  /// In ar, this message translates to:
  /// **'ايقاف الأذان عند قلب الجهاز'**
  String get adhanFlipToSilenceLabel;

  /// No description provided for @adhanFlipToSilenceSublabel.
  ///
  /// In ar, this message translates to:
  /// **'اقلب الهاتف على وجهه لإسكات صوت الأذان'**
  String get adhanFlipToSilenceSublabel;

  /// No description provided for @adhanAlarmNotifLabel.
  ///
  /// In ar, this message translates to:
  /// **'إشعار الأذان بالجرس المنبه'**
  String get adhanAlarmNotifLabel;

  /// No description provided for @adhanAlarmNotifSublabel.
  ///
  /// In ar, this message translates to:
  /// **'التنبيه حتى في وضع الصامت'**
  String get adhanAlarmNotifSublabel;

  /// No description provided for @adhanOngoingNotifLabel.
  ///
  /// In ar, this message translates to:
  /// **'إشعار دائم بأوقات الصلاة'**
  String get adhanOngoingNotifLabel;

  /// No description provided for @adhanOngoingNotifSublabel.
  ///
  /// In ar, this message translates to:
  /// **'إظهار شريط إشعار دائم بالمتبقي للصلاة'**
  String get adhanOngoingNotifSublabel;

  /// AppBar title on the About the Developer screen
  ///
  /// In ar, this message translates to:
  /// **'عن المطور'**
  String get aboutScreenTitle;

  /// Section heading: about the developer
  ///
  /// In ar, this message translates to:
  /// **'عن المطور'**
  String get aboutSectionDeveloper;

  /// Section heading: technical skills
  ///
  /// In ar, this message translates to:
  /// **'المهارات التقنية'**
  String get aboutSectionSkills;

  /// Section heading: connect with me / social links
  ///
  /// In ar, this message translates to:
  /// **'تواصل معي'**
  String get aboutSectionConnect;

  /// Developer's full name in Arabic
  ///
  /// In ar, this message translates to:
  /// **'عماد الدين عينين'**
  String get aboutDevNameArabic;

  /// Developer's full name in Latin script
  ///
  /// In ar, this message translates to:
  /// **'Imadeddine Ainine'**
  String get aboutDevNameLatin;

  /// Role badge shown under the developer's name
  ///
  /// In ar, this message translates to:
  /// **'Fullstack Developer'**
  String get aboutDevBadge;

  /// Short developer biography shown on the About screen
  ///
  /// In ar, this message translates to:
  /// **'مطور برمجيات شغوف ببناء تطبيقات الهاتف والمواقع الإلكترونية بأحدث التقنيات. أهتم بجودة الكود وتجربة المستخدم، وأسعى دوماً لتقديم حلول تقنية مبتكرة تخدم المجتمع المسلم.'**
  String get aboutBio;

  /// Footer line asking users to make dua for the developer
  ///
  /// In ar, this message translates to:
  /// **'ادعوا لي من خالص دعائكم'**
  String get aboutFooterDuaRequest;

  /// Footer tagline: made with love for the Muslim community
  ///
  /// In ar, this message translates to:
  /// **'صنع بكل حب للأمة الإسلامية'**
  String get aboutFooterMadeWithLove;

  /// Copyright line in the About screen footer
  ///
  /// In ar, this message translates to:
  /// **'© 2026 - Imadeddine Ainine'**
  String get aboutFooterCopyright;

  /// AppBar title on the Khatma progress screen
  ///
  /// In ar, this message translates to:
  /// **'تقدم الختمة'**
  String get khatmaScreenTitle;

  /// Progress label, e.g. '9.9٪ مكتملة'
  ///
  /// In ar, this message translates to:
  /// **'{percent}٪ مكتملة'**
  String khatmaProgressPercent(String percent);

  /// Stat card label: number of completed khatmas
  ///
  /// In ar, this message translates to:
  /// **'ختمات مكتملة'**
  String get khatmaStatCompletedLabel;

  /// Stat card label: consecutive days reading
  ///
  /// In ar, this message translates to:
  /// **'أيام متواصلة'**
  String get khatmaStatStreakLabel;

  /// Stat card label: average pages per day
  ///
  /// In ar, this message translates to:
  /// **'صفحة/يوم'**
  String get khatmaStatPagesPerDayLabel;

  /// Title above the weekly reading bar chart
  ///
  /// In ar, this message translates to:
  /// **'القراءة الأسبوعية'**
  String get khatmaWeeklyChartTitle;

  /// No description provided for @khatmaDaySun.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get khatmaDaySun;

  /// No description provided for @khatmaDayMon.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين'**
  String get khatmaDayMon;

  /// No description provided for @khatmaDayTue.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get khatmaDayTue;

  /// No description provided for @khatmaDayWed.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get khatmaDayWed;

  /// No description provided for @khatmaDayThu.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get khatmaDayThu;

  /// No description provided for @khatmaDayFri.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get khatmaDayFri;

  /// No description provided for @khatmaDaySat.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get khatmaDaySat;

  /// Full weekday name: Sunday
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get weekdayFullSunday;

  /// Two-letter weekday abbreviation: Sunday
  ///
  /// In ar, this message translates to:
  /// **'أح'**
  String get weekdayShortSunday;

  /// Single-letter weekday initial: Sunday
  ///
  /// In ar, this message translates to:
  /// **'ح'**
  String get weekdayInitialSunday;

  /// Full weekday name: Monday
  ///
  /// In ar, this message translates to:
  /// **'الإثنين'**
  String get weekdayFullMonday;

  /// Two-letter weekday abbreviation: Monday
  ///
  /// In ar, this message translates to:
  /// **'إث'**
  String get weekdayShortMonday;

  /// Single-letter weekday initial: Monday
  ///
  /// In ar, this message translates to:
  /// **'ن'**
  String get weekdayInitialMonday;

  /// Full weekday name: Tuesday
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get weekdayFullTuesday;

  /// Two-letter weekday abbreviation: Tuesday
  ///
  /// In ar, this message translates to:
  /// **'ثل'**
  String get weekdayShortTuesday;

  /// Single-letter weekday initial: Tuesday
  ///
  /// In ar, this message translates to:
  /// **'ث'**
  String get weekdayInitialTuesday;

  /// Full weekday name: Wednesday
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get weekdayFullWednesday;

  /// Two-letter weekday abbreviation: Wednesday
  ///
  /// In ar, this message translates to:
  /// **'أر'**
  String get weekdayShortWednesday;

  /// Single-letter weekday initial: Wednesday
  ///
  /// In ar, this message translates to:
  /// **'ر'**
  String get weekdayInitialWednesday;

  /// Full weekday name: Thursday
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get weekdayFullThursday;

  /// Two-letter weekday abbreviation: Thursday
  ///
  /// In ar, this message translates to:
  /// **'خم'**
  String get weekdayShortThursday;

  /// Single-letter weekday initial: Thursday
  ///
  /// In ar, this message translates to:
  /// **'خ'**
  String get weekdayInitialThursday;

  /// Full weekday name: Friday
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get weekdayFullFriday;

  /// Two-letter weekday abbreviation: Friday
  ///
  /// In ar, this message translates to:
  /// **'جم'**
  String get weekdayShortFriday;

  /// Single-letter weekday initial: Friday
  ///
  /// In ar, this message translates to:
  /// **'ج'**
  String get weekdayInitialFriday;

  /// Full weekday name: Saturday
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get weekdayFullSaturday;

  /// Two-letter weekday abbreviation: Saturday
  ///
  /// In ar, this message translates to:
  /// **'سب'**
  String get weekdayShortSaturday;

  /// Single-letter weekday initial: Saturday
  ///
  /// In ar, this message translates to:
  /// **'س'**
  String get weekdayInitialSaturday;

  /// The app's own name/brand
  ///
  /// In ar, this message translates to:
  /// **'تقوى'**
  String get appName;

  /// No description provided for @onboardingSignInSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك لحفظ بياناتك ومزامنتها'**
  String get onboardingSignInSubtitle;

  /// No description provided for @onboardingBenefitSaveProgress.
  ///
  /// In ar, this message translates to:
  /// **'حفظ بياناتك وتقدمك'**
  String get onboardingBenefitSaveProgress;

  /// No description provided for @onboardingBenefitCompete.
  ///
  /// In ar, this message translates to:
  /// **'التنافس مع المسلمين حول العالم'**
  String get onboardingBenefitCompete;

  /// No description provided for @onboardingBenefitStats.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات مفصلة ومتقدمة'**
  String get onboardingBenefitStats;

  /// No description provided for @onboardingBenefitSync.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة تلقائية بين أجهزتك'**
  String get onboardingBenefitSync;

  /// No description provided for @onboardingContinueWithoutAccount.
  ///
  /// In ar, this message translates to:
  /// **'متابعة بدون حساب'**
  String get onboardingContinueWithoutAccount;

  /// No description provided for @onboardingChoosePlanTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر خطتك'**
  String get onboardingChoosePlanTitle;

  /// No description provided for @onboardingChoosePlanSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلى عائلة تقوى'**
  String get onboardingChoosePlanSubtitle;

  /// No description provided for @onboardingPremiumTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقوى ⭐ Premium'**
  String get onboardingPremiumTitle;

  /// No description provided for @onboardingPremiumDesc.
  ///
  /// In ar, this message translates to:
  /// **'بلا إعلانات + إحصائيات متقدمة + مزامنة سحابية + دعم أولوي'**
  String get onboardingPremiumDesc;

  /// No description provided for @onboardingPremiumBadge.
  ///
  /// In ar, this message translates to:
  /// **'الأفضل'**
  String get onboardingPremiumBadge;

  /// Hardcoded Algerian Dinar price — not currency-aware
  ///
  /// In ar, this message translates to:
  /// **'99 دج / شهر'**
  String get onboardingPremiumPrice;

  /// No description provided for @onboardingPremiumFeature1.
  ///
  /// In ar, this message translates to:
  /// **'بلا إعلانات نهائياً'**
  String get onboardingPremiumFeature1;

  /// No description provided for @onboardingPremiumFeature2.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات متقدمة ورسوم بيانية'**
  String get onboardingPremiumFeature2;

  /// No description provided for @onboardingPremiumFeature3.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة سحابية تلقائية'**
  String get onboardingPremiumFeature3;

  /// No description provided for @onboardingPremiumFeature4.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات مخصصة لا نهاية لها'**
  String get onboardingPremiumFeature4;

  /// No description provided for @onboardingPremiumFeature5.
  ///
  /// In ar, this message translates to:
  /// **'أولوية في الدعم الفني'**
  String get onboardingPremiumFeature5;

  /// No description provided for @onboardingFreeTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقوى 🌙 مجاني'**
  String get onboardingFreeTitle;

  /// No description provided for @onboardingFreeDesc.
  ///
  /// In ar, this message translates to:
  /// **'جميع الميزات الأساسية مع إعلانات بسيطة للإبقاء على الخدمة'**
  String get onboardingFreeDesc;

  /// No description provided for @onboardingFreeFeature1.
  ///
  /// In ar, this message translates to:
  /// **'جميع ميزات المحاسبة'**
  String get onboardingFreeFeature1;

  /// No description provided for @onboardingFreeFeature2.
  ///
  /// In ar, this message translates to:
  /// **'أوقات الصلاة والقبلة'**
  String get onboardingFreeFeature2;

  /// No description provided for @onboardingFreeFeature3.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار والأدعية'**
  String get onboardingFreeFeature3;

  /// No description provided for @onboardingFreeFeature4.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات بسيطة'**
  String get onboardingFreeFeature4;

  /// No description provided for @onboardingStartPremiumCta.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ Premium 🌟'**
  String get onboardingStartPremiumCta;

  /// No description provided for @onboardingStartFreeCta.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ مجاناً 🤲'**
  String get onboardingStartFreeCta;

  /// Decorative demo text in an onboarding illustration graphic
  ///
  /// In ar, this message translates to:
  /// **'سبحان الله'**
  String get onboardingDemoTasbeehText;

  /// No description provided for @notifChannelPrayerSoundName.
  ///
  /// In ar, this message translates to:
  /// **'أذان الصلاة (صوت)'**
  String get notifChannelPrayerSoundName;

  /// No description provided for @notifChannelPrayerSoundDesc.
  ///
  /// In ar, this message translates to:
  /// **'إشعار وقت الأذان مع صوت الأذان'**
  String get notifChannelPrayerSoundDesc;

  /// No description provided for @notifChannelPrayerVibrateName.
  ///
  /// In ar, this message translates to:
  /// **'أذان الصلاة (اهتزاز)'**
  String get notifChannelPrayerVibrateName;

  /// No description provided for @notifChannelPrayerVibrateDesc.
  ///
  /// In ar, this message translates to:
  /// **'إشعار وقت الأذان باهتزاز فقط'**
  String get notifChannelPrayerVibrateDesc;

  /// No description provided for @notifChannelPrayerSilentName.
  ///
  /// In ar, this message translates to:
  /// **'أذان الصلاة (صامت)'**
  String get notifChannelPrayerSilentName;

  /// No description provided for @notifChannelPrayerSilentDesc.
  ///
  /// In ar, this message translates to:
  /// **'إشعار صامت لوقت الأذان'**
  String get notifChannelPrayerSilentDesc;

  /// No description provided for @notifChannelAlertName.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الصلاة'**
  String get notifChannelAlertName;

  /// No description provided for @notifChannelAlertDesc.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات قبل الأذان وبعد الإقامة'**
  String get notifChannelAlertDesc;

  /// No description provided for @notifChannelMuhasabaName.
  ///
  /// In ar, this message translates to:
  /// **'محاسبة النفس'**
  String get notifChannelMuhasabaName;

  /// No description provided for @notifChannelMuhasabaDesc.
  ///
  /// In ar, this message translates to:
  /// **'تذكير محاسبة النفس المسائية'**
  String get notifChannelMuhasabaDesc;

  /// No description provided for @notifChannelAdhkarName.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار اليومية'**
  String get notifChannelAdhkarName;

  /// No description provided for @notifChannelAdhkarDesc.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح والمساء وبعد الصلاة'**
  String get notifChannelAdhkarDesc;

  /// No description provided for @notifChannelDuasName.
  ///
  /// In ar, this message translates to:
  /// **'الأدعية'**
  String get notifChannelDuasName;

  /// No description provided for @notifChannelDuasDesc.
  ///
  /// In ar, this message translates to:
  /// **'نفحات من الأدعية النبوية والقرآنية'**
  String get notifChannelDuasDesc;

  /// No description provided for @notifChannelAchievementName.
  ///
  /// In ar, this message translates to:
  /// **'الإنجازات'**
  String get notifChannelAchievementName;

  /// No description provided for @notifChannelAchievementDesc.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الإنجازات الجديدة'**
  String get notifChannelAchievementDesc;

  /// No description provided for @notifChannelRemindersName.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات إيمانية'**
  String get notifChannelRemindersName;

  /// No description provided for @notifChannelRemindersDesc.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات بسنن الجمعة والصيام والأيام البيض'**
  String get notifChannelRemindersDesc;

  /// No description provided for @notifChannelRamadanName.
  ///
  /// In ar, this message translates to:
  /// **'رمضان المبارك'**
  String get notifChannelRamadanName;

  /// No description provided for @notifChannelRamadanDesc.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات السحور والإفطار'**
  String get notifChannelRamadanDesc;

  /// No description provided for @notifChannelWakeUpAlarmName.
  ///
  /// In ar, this message translates to:
  /// **'منبه الاستيقاظ'**
  String get notifChannelWakeUpAlarmName;

  /// No description provided for @notifChannelWakeUpAlarmDesc.
  ///
  /// In ar, this message translates to:
  /// **'منبه مخصص للاستيقاظ لصلاة الفجر'**
  String get notifChannelWakeUpAlarmDesc;

  /// No description provided for @overlayServiceChannelDesc.
  ///
  /// In ar, this message translates to:
  /// **'يُبقي خدمة الأذان والأذكار نشطة'**
  String get overlayServiceChannelDesc;

  /// No description provided for @overlayServiceLoadingPrayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل أوقات الصلاة...'**
  String get overlayServiceLoadingPrayerTimes;

  /// No description provided for @overlayServiceOpenAppButton.
  ///
  /// In ar, this message translates to:
  /// **'افتح تقوى'**
  String get overlayServiceOpenAppButton;

  /// No description provided for @overlayServiceUpdateLocationButton.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموقع'**
  String get overlayServiceUpdateLocationButton;

  /// No description provided for @overlayServiceUpdatingLocation.
  ///
  /// In ar, this message translates to:
  /// **'🔄 جاري تحديث الموقع...'**
  String get overlayServiceUpdatingLocation;

  /// No description provided for @overlayServiceDefaultCity.
  ///
  /// In ar, this message translates to:
  /// **'الجزائر'**
  String get overlayServiceDefaultCity;

  /// No description provided for @overlayServiceUnknownCity.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get overlayServiceUnknownCity;

  /// No description provided for @overlayServicePrayerTimeOverlayTitle.
  ///
  /// In ar, this message translates to:
  /// **'وقت الصلاة'**
  String get overlayServicePrayerTimeOverlayTitle;

  /// No description provided for @overlayServicePrayerTimeOverlayContent.
  ///
  /// In ar, this message translates to:
  /// **'حان الآن موعد أذان {prayer}'**
  String overlayServicePrayerTimeOverlayContent(String prayer);

  /// No description provided for @overlayServiceDuaOverlayTitle.
  ///
  /// In ar, this message translates to:
  /// **'دعاء من تقوى'**
  String get overlayServiceDuaOverlayTitle;

  /// No description provided for @overlayServiceAdhkarOverlayTitle.
  ///
  /// In ar, this message translates to:
  /// **'أذكار تقوى'**
  String get overlayServiceAdhkarOverlayTitle;

  /// No description provided for @overlayServiceDuaOverlayContent.
  ///
  /// In ar, this message translates to:
  /// **'دعاء'**
  String get overlayServiceDuaOverlayContent;

  /// No description provided for @overlayServiceAdhkarOverlayContent.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get overlayServiceAdhkarOverlayContent;

  /// No description provided for @prayerScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'أوقات الصلاة'**
  String get prayerScreenTitle;

  /// No description provided for @prayerScreenIqamaTimeFor.
  ///
  /// In ar, this message translates to:
  /// **'وقت الإقامة — {prayer}'**
  String prayerScreenIqamaTimeFor(String prayer);

  /// No description provided for @prayerScreenPrayerFor.
  ///
  /// In ar, this message translates to:
  /// **'صلاة {prayer}'**
  String prayerScreenPrayerFor(String prayer);

  /// No description provided for @prayerScreenEstablishPrayer.
  ///
  /// In ar, this message translates to:
  /// **'أقم الصلاة'**
  String get prayerScreenEstablishPrayer;

  /// No description provided for @prayerScreenNextPrayerLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get prayerScreenNextPrayerLabel;

  /// No description provided for @prayerScreenIqamaCountdownLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإقامة بعد'**
  String get prayerScreenIqamaCountdownLabel;

  /// No description provided for @prayerScreenAdhanCountdownLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأذان بعد'**
  String get prayerScreenAdhanCountdownLabel;

  /// No description provided for @prayerScreenGetReady.
  ///
  /// In ar, this message translates to:
  /// **'استعد'**
  String get prayerScreenGetReady;

  /// No description provided for @prayerScreenAdhanTimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وقت الأذان'**
  String get prayerScreenAdhanTimeLabel;

  /// No description provided for @prayerScreenSalvationSlogan.
  ///
  /// In ar, this message translates to:
  /// **'صلاتك نجاتك'**
  String get prayerScreenSalvationSlogan;

  /// No description provided for @prayerScreenIqamaTimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وقت الإقامة'**
  String get prayerScreenIqamaTimeLabel;

  /// No description provided for @prayerScreenIqamaOffsetShort.
  ///
  /// In ar, this message translates to:
  /// **'+{minutes}د'**
  String prayerScreenIqamaOffsetShort(int minutes);

  /// No description provided for @prayerScreenIqamaAfterMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{بعد دقيقة واحدة} two{بعد دقيقتين} few{بعد {count} دقائق} many{بعد {count} دقيقة} other{بعد {count} دقيقة}}'**
  String prayerScreenIqamaAfterMinutes(num count);

  /// No description provided for @prayerScreenTodaysPrayers.
  ///
  /// In ar, this message translates to:
  /// **'صلوات اليوم'**
  String get prayerScreenTodaysPrayers;

  /// No description provided for @prayerScreenAdhanNowBadge.
  ///
  /// In ar, this message translates to:
  /// **'الأذان الآن'**
  String get prayerScreenAdhanNowBadge;

  /// No description provided for @prayerScreenSunriseBadge.
  ///
  /// In ar, this message translates to:
  /// **'شروق'**
  String get prayerScreenSunriseBadge;

  /// No description provided for @prayerScreenAdhanBadge.
  ///
  /// In ar, this message translates to:
  /// **'أذان'**
  String get prayerScreenAdhanBadge;

  /// No description provided for @prayerScreenIqamaBadge.
  ///
  /// In ar, this message translates to:
  /// **'إقامة'**
  String get prayerScreenIqamaBadge;

  /// No description provided for @prayerScreenLocationErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديد الموقع'**
  String get prayerScreenLocationErrorTitle;

  /// No description provided for @prayerScreenLocationErrorSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من تفعيل GPS'**
  String get prayerScreenLocationErrorSubtitle;

  /// No description provided for @prayerScreenRetryButton.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get prayerScreenRetryButton;

  /// No description provided for @quranReaderFallbackName.
  ///
  /// In ar, this message translates to:
  /// **'القرآن'**
  String get quranReaderFallbackName;

  /// No description provided for @quranReaderMeccan.
  ///
  /// In ar, this message translates to:
  /// **'مكية'**
  String get quranReaderMeccan;

  /// No description provided for @quranReaderMedinan.
  ///
  /// In ar, this message translates to:
  /// **'مدنية'**
  String get quranReaderMedinan;

  /// No description provided for @quranReaderSurahHeaderTitle.
  ///
  /// In ar, this message translates to:
  /// **'سُورَةُ {name}'**
  String quranReaderSurahHeaderTitle(String name);

  /// No description provided for @quranReaderAyahCountBadge.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{آية واحدة} two{آيتان} few{{count} آيات} many{{count} آية} other{{count} آية}}'**
  String quranReaderAyahCountBadge(num count);

  /// No description provided for @quranReaderSurahLabel.
  ///
  /// In ar, this message translates to:
  /// **'سورة {name}'**
  String quranReaderSurahLabel(String name);

  /// No description provided for @quranReaderAyahRefLabel.
  ///
  /// In ar, this message translates to:
  /// **'الآية {ayah} — سورة {surah}'**
  String quranReaderAyahRefLabel(String ayah, String surah);

  /// No description provided for @quranReaderJuzChip.
  ///
  /// In ar, this message translates to:
  /// **'جزء: {juz}'**
  String quranReaderJuzChip(String juz);

  /// No description provided for @quranReaderPageOfTotalChip.
  ///
  /// In ar, this message translates to:
  /// **'صفحة: {current} من {total}'**
  String quranReaderPageOfTotalChip(String current, String total);

  /// No description provided for @quranReaderReadCountChip.
  ///
  /// In ar, this message translates to:
  /// **'قرأت {read} من {total} صفحات'**
  String quranReaderReadCountChip(String read, String total);

  /// No description provided for @quranReaderGuideTitle.
  ///
  /// In ar, this message translates to:
  /// **'دليل القراءة'**
  String get quranReaderGuideTitle;

  /// No description provided for @quranReaderGuideTapToggle.
  ///
  /// In ar, this message translates to:
  /// **'اضغط ضغطة واحدة لإظهار أو إخفاء أزرار التحكم'**
  String get quranReaderGuideTapToggle;

  /// No description provided for @quranReaderGuideDoubleTapZoom.
  ///
  /// In ar, this message translates to:
  /// **'اضغط مرتين للتكبير والتصغير'**
  String get quranReaderGuideDoubleTapZoom;

  /// No description provided for @quranReaderGuideSwipeNavigate.
  ///
  /// In ar, this message translates to:
  /// **'اسحب يميناً أو يساراً للتنقل بين الصفحات'**
  String get quranReaderGuideSwipeNavigate;

  /// No description provided for @quranReaderGuideLongPress.
  ///
  /// In ar, this message translates to:
  /// **'اضغط مطولاً على أي آية لعرض:'**
  String get quranReaderGuideLongPress;

  /// No description provided for @quranReaderGuideSaveAyah.
  ///
  /// In ar, this message translates to:
  /// **'⭐ حفظ الآية كمرجع'**
  String get quranReaderGuideSaveAyah;

  /// No description provided for @quranReaderGuideShareAyah.
  ///
  /// In ar, this message translates to:
  /// **'📤 مشاركة الآية (نص أو صورة أو فيديو)'**
  String get quranReaderGuideShareAyah;

  /// No description provided for @quranReaderGuideTafsir.
  ///
  /// In ar, this message translates to:
  /// **'📖 التفسير الميسر'**
  String get quranReaderGuideTafsir;

  /// No description provided for @quranReaderGuideTranslation.
  ///
  /// In ar, this message translates to:
  /// **'🌐 الترجمة'**
  String get quranReaderGuideTranslation;

  /// No description provided for @quranReaderGuideListen.
  ///
  /// In ar, this message translates to:
  /// **'🔊 استماع للآية أو الصفحة أو السورة'**
  String get quranReaderGuideListen;

  /// No description provided for @quranReaderGuideAudioButton.
  ///
  /// In ar, this message translates to:
  /// **'زر السماعة في الأعلى للاستماع للصفحة كاملة'**
  String get quranReaderGuideAudioButton;

  /// No description provided for @quranReaderGuideNightModeButton.
  ///
  /// In ar, this message translates to:
  /// **'زر الوضع الليلي لتبديل المظهر'**
  String get quranReaderGuideNightModeButton;

  /// No description provided for @quranReaderGuideGotIt.
  ///
  /// In ar, this message translates to:
  /// **'فهمت ✓'**
  String get quranReaderGuideGotIt;

  /// No description provided for @quranReaderPageJumpError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم صحيح بين ١ و {max}'**
  String quranReaderPageJumpError(String max);

  /// No description provided for @quranReaderGoToPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'الانتقال إلى صفحة'**
  String get quranReaderGoToPageTitle;

  /// No description provided for @quranReaderCurrentPageLabel.
  ///
  /// In ar, this message translates to:
  /// **'أنت الآن في صفحة {page}'**
  String quranReaderCurrentPageLabel(String page);

  /// No description provided for @quranReaderPageInputLabel.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الصفحة ({range})'**
  String quranReaderPageInputLabel(String range);

  /// No description provided for @quranReaderPageRangeHint.
  ///
  /// In ar, this message translates to:
  /// **'١ - {max}'**
  String quranReaderPageRangeHint(String max);

  /// No description provided for @quranReaderCancelButton.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get quranReaderCancelButton;

  /// No description provided for @quranReaderGoButton.
  ///
  /// In ar, this message translates to:
  /// **'انتقال'**
  String get quranReaderGoButton;

  /// No description provided for @quranReaderSaveAyahOption.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الآية كمرجع'**
  String get quranReaderSaveAyahOption;

  /// No description provided for @quranReaderShareAyahOption.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الآية'**
  String get quranReaderShareAyahOption;

  /// No description provided for @quranReaderTafsirOption.
  ///
  /// In ar, this message translates to:
  /// **'التفسير الميسر'**
  String get quranReaderTafsirOption;

  /// No description provided for @quranReaderTranslationOption.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة'**
  String get quranReaderTranslationOption;

  /// No description provided for @quranReaderListenAyahOption.
  ///
  /// In ar, this message translates to:
  /// **'استماع للآية'**
  String get quranReaderListenAyahOption;

  /// No description provided for @quranReaderSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات القراءة'**
  String get quranReaderSettingsTitle;

  /// No description provided for @quranReaderFontSizeLabel.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get quranReaderFontSizeLabel;

  /// No description provided for @quranReaderBackgroundStyleLabel.
  ///
  /// In ar, this message translates to:
  /// **'نمط الخلفية'**
  String get quranReaderBackgroundStyleLabel;

  /// No description provided for @quranReaderThemeNight.
  ///
  /// In ar, this message translates to:
  /// **'ليلي'**
  String get quranReaderThemeNight;

  /// No description provided for @quranReaderThemeSepia.
  ///
  /// In ar, this message translates to:
  /// **'عاجي'**
  String get quranReaderThemeSepia;

  /// No description provided for @quranReaderThemeWhite.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get quranReaderThemeWhite;

  /// No description provided for @createKhatmaDefaultNamePrefix.
  ///
  /// In ar, this message translates to:
  /// **'ختمة {monthYear}'**
  String createKhatmaDefaultNamePrefix(String monthYear);

  /// No description provided for @createKhatmaTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء ختمة جديدة'**
  String get createKhatmaTitle;

  /// No description provided for @createKhatmaNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الختمة'**
  String get createKhatmaNameLabel;

  /// No description provided for @createKhatmaTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الختمة'**
  String get createKhatmaTypeLabel;

  /// No description provided for @createKhatmaTypeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الختمة التي تريد إنشاءها'**
  String get createKhatmaTypeSubtitle;

  /// No description provided for @createKhatmaTypeMuyassaraTitle.
  ///
  /// In ar, this message translates to:
  /// **'ختمة ميسرة'**
  String get createKhatmaTypeMuyassaraTitle;

  /// No description provided for @createKhatmaTypeMuyassaraDesc.
  ///
  /// In ar, this message translates to:
  /// **'قراءة القرآن كاملاً بالترتيب بدون ورد يومي محدد أو وقت ختم محدد'**
  String get createKhatmaTypeMuyassaraDesc;

  /// No description provided for @createKhatmaTypeMultazimaTitle.
  ///
  /// In ar, this message translates to:
  /// **'ختمة ملتزمة'**
  String get createKhatmaTypeMultazimaTitle;

  /// No description provided for @createKhatmaTypeMultazimaDesc.
  ///
  /// In ar, this message translates to:
  /// **'ختمة مع ورد يومي محدد ووقت ختم محدد'**
  String get createKhatmaTypeMultazimaDesc;

  /// No description provided for @createKhatmaStartDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البداية'**
  String get createKhatmaStartDateLabel;

  /// No description provided for @createKhatmaStartPageLabel.
  ///
  /// In ar, this message translates to:
  /// **'صفحة البداية'**
  String get createKhatmaStartPageLabel;

  /// No description provided for @createKhatmaPageOption.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {n}'**
  String createKhatmaPageOption(String n);

  /// No description provided for @createKhatmaEnableNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get createKhatmaEnableNotifications;

  /// No description provided for @createKhatmaNotificationsDisabledWarning.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات معطلة - لن يتم إرسال أي تذكرات'**
  String get createKhatmaNotificationsDisabledWarning;

  /// No description provided for @createKhatmaSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الختمة'**
  String get createKhatmaSummaryTitle;

  /// No description provided for @createKhatmaTypeFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الختمة:'**
  String get createKhatmaTypeFieldLabel;

  /// No description provided for @createKhatmaNameFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الختمة:'**
  String get createKhatmaNameFieldLabel;

  /// No description provided for @createKhatmaStartDateFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البداية:'**
  String get createKhatmaStartDateFieldLabel;

  /// No description provided for @createKhatmaFirstPageFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة الأولى:'**
  String get createKhatmaFirstPageFieldLabel;

  /// No description provided for @createKhatmaNotificationsFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات:'**
  String get createKhatmaNotificationsFieldLabel;

  /// No description provided for @createKhatmaNotificationsEnabledValue.
  ///
  /// In ar, this message translates to:
  /// **'مفعّلة'**
  String get createKhatmaNotificationsEnabledValue;

  /// No description provided for @createKhatmaNotificationsDisabledValue.
  ///
  /// In ar, this message translates to:
  /// **'معطلة'**
  String get createKhatmaNotificationsDisabledValue;

  /// No description provided for @createKhatmaStartReadingHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك البدء في القراءة فوراً بعد إنشاء الختمة'**
  String get createKhatmaStartReadingHint;

  /// No description provided for @createKhatmaPreviousButton.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get createKhatmaPreviousButton;

  /// No description provided for @createKhatmaNextButton.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get createKhatmaNextButton;

  /// No description provided for @createKhatmaCreateButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الختمة'**
  String get createKhatmaCreateButton;

  /// No description provided for @createKhatmaDefaultLabelFallback.
  ///
  /// In ar, this message translates to:
  /// **'ختمة جديدة'**
  String get createKhatmaDefaultLabelFallback;

  /// No description provided for @createKhatmaSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الختمة بنجاح'**
  String get createKhatmaSuccessMessage;

  /// No description provided for @userAdhkarAddButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ذكر'**
  String get userAdhkarAddButton;

  /// No description provided for @userAdhkarEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'أذكاري الخاصة'**
  String get userAdhkarEmptyTitle;

  /// No description provided for @userAdhkarEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أذكار مضافة حالياً.\nاضغط على الزر لإضافة ذكرك الأول.'**
  String get userAdhkarEmptyBody;

  /// No description provided for @adhkarGenericError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String adhkarGenericError(String error);

  /// No description provided for @adhkarCopyTooltip.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get adhkarCopyTooltip;

  /// No description provided for @adhkarCopiedSnackbar.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get adhkarCopiedSnackbar;

  /// No description provided for @adhkarShareWithCommunity.
  ///
  /// In ar, this message translates to:
  /// **'شارك مع المجتمع'**
  String get adhkarShareWithCommunity;

  /// No description provided for @adhkarDeleteTooltip.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get adhkarDeleteTooltip;

  /// No description provided for @adhkarDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الذكر؟'**
  String get adhkarDeleteConfirmTitle;

  /// No description provided for @adhkarDeleteConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا الذكر نهائياً؟'**
  String get adhkarDeleteConfirmBody;

  /// No description provided for @adhkarCancelButton.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get adhkarCancelButton;

  /// No description provided for @adhkarShareToCommunityTitle.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة مع المجتمع'**
  String get adhkarShareToCommunityTitle;

  /// No description provided for @adhkarShareToCommunityDesc.
  ///
  /// In ar, this message translates to:
  /// **'سيُضاف الذكر للمراجعة ثم يظهر في تبويب المجتمع'**
  String get adhkarShareToCommunityDesc;

  /// No description provided for @adhkarCountTimesLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{مرة واحدة} two{مرتان} few{{count} مرات} many{{count} مرة} other{{count} مرة}}'**
  String adhkarCountTimesLabel(num count);

  /// No description provided for @adhkarSharedSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تمت المشاركة بنجاح!'**
  String get adhkarSharedSuccessMessage;

  /// No description provided for @communityAdhkarEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'مجتمع الأذكار'**
  String get communityAdhkarEmptyTitle;

  /// No description provided for @communityAdhkarEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشاركات من المجتمع حالياً.\nشارك أذكارك من تبويب \"أذكاري\".'**
  String get communityAdhkarEmptyBody;

  /// No description provided for @communityAdhkarRetryButton.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get communityAdhkarRetryButton;

  /// No description provided for @addAdhkarSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ذكر جديد'**
  String get addAdhkarSheetTitle;

  /// No description provided for @addAdhkarTextHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الذكر هنا بحروف عربية واضحة...'**
  String get addAdhkarTextHint;

  /// No description provided for @addAdhkarRepeatCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد التكرار:'**
  String get addAdhkarRepeatCountLabel;

  /// No description provided for @addAdhkarShareToggleDesc.
  ///
  /// In ar, this message translates to:
  /// **'يُضاف الذكر للمراجعة ثم يظهر للجميع'**
  String get addAdhkarShareToggleDesc;

  /// No description provided for @addAdhkarAndShareButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ومشاركة مع المجتمع'**
  String get addAdhkarAndShareButton;

  /// No description provided for @addAdhkarButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة الذكر'**
  String get addAdhkarButton;

  /// No description provided for @locationResultSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الموقع بنجاح ✓'**
  String get locationResultSuccess;

  /// No description provided for @locationResultServiceDisabled.
  ///
  /// In ar, this message translates to:
  /// **'GPS غير مفعّل، يرجى تفعيله'**
  String get locationResultServiceDisabled;

  /// No description provided for @locationResultPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الموقع'**
  String get locationResultPermissionDenied;

  /// No description provided for @locationResultPermissionDeniedForever.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تفعيل إذن الموقع من الإعدادات'**
  String get locationResultPermissionDeniedForever;

  /// No description provided for @locationResultError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحديد الموقع'**
  String get locationResultError;

  /// No description provided for @locationEnableAction.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get locationEnableAction;

  /// No description provided for @locationUpdateTileLabel.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموقع وأوقات الصلاة'**
  String get locationUpdateTileLabel;

  /// No description provided for @timezoneAlgiers.
  ///
  /// In ar, this message translates to:
  /// **'الجزائر (UTC+1)'**
  String get timezoneAlgiers;

  /// No description provided for @timezoneTunis.
  ///
  /// In ar, this message translates to:
  /// **'تونس (UTC+1)'**
  String get timezoneTunis;

  /// No description provided for @timezoneEgypt.
  ///
  /// In ar, this message translates to:
  /// **'مصر (UTC+2)'**
  String get timezoneEgypt;

  /// No description provided for @timezoneRiyadh.
  ///
  /// In ar, this message translates to:
  /// **'الرياض (UTC+3)'**
  String get timezoneRiyadh;

  /// No description provided for @timezoneDubai.
  ///
  /// In ar, this message translates to:
  /// **'دبي (UTC+4)'**
  String get timezoneDubai;

  /// No description provided for @timezoneKuwait.
  ///
  /// In ar, this message translates to:
  /// **'الكويت (UTC+3)'**
  String get timezoneKuwait;

  /// No description provided for @timezoneBeirut.
  ///
  /// In ar, this message translates to:
  /// **'بيروت (UTC+3)'**
  String get timezoneBeirut;

  /// No description provided for @timezoneJerusalem.
  ///
  /// In ar, this message translates to:
  /// **'القدس (UTC+3)'**
  String get timezoneJerusalem;

  /// No description provided for @locationPickerLocationSetTo.
  ///
  /// In ar, this message translates to:
  /// **'تم تحيين الموقع إلى {city} ✓'**
  String locationPickerLocationSetTo(String city);

  /// No description provided for @locationPickerTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموقع الجغرافي'**
  String get locationPickerTitle;

  /// No description provided for @locationPickerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر موقعك بدقة لحساب أوقات الصلاة'**
  String get locationPickerSubtitle;

  /// No description provided for @locationPickerOrChooseCity.
  ///
  /// In ar, this message translates to:
  /// **'أو اختر مدينة رئيسية'**
  String get locationPickerOrChooseCity;

  /// No description provided for @locationPickerAutoDetectTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع تلقائياً'**
  String get locationPickerAutoDetectTitle;

  /// No description provided for @locationPickerAutoDetectSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'باستخدام GPS'**
  String get locationPickerAutoDetectSubtitle;

  /// No description provided for @locationPickerSelectButton.
  ///
  /// In ar, this message translates to:
  /// **'اختر'**
  String get locationPickerSelectButton;

  /// No description provided for @manageIbadahTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العادات'**
  String get manageIbadahTitle;

  /// No description provided for @manageIbadahPositiveTab.
  ///
  /// In ar, this message translates to:
  /// **'إيجابية'**
  String get manageIbadahPositiveTab;

  /// No description provided for @manageIbadahNegativeTab.
  ///
  /// In ar, this message translates to:
  /// **'سلبية (محظورات)'**
  String get manageIbadahNegativeTab;

  /// No description provided for @manageIbadahEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عادات مضافة بعد'**
  String get manageIbadahEmpty;

  /// No description provided for @manageIbadahLoadError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل البيانات'**
  String get manageIbadahLoadError;

  /// No description provided for @manageIbadahPointsEarned.
  ///
  /// In ar, this message translates to:
  /// **'النقاط: {points}'**
  String manageIbadahPointsEarned(String points);

  /// No description provided for @manageIbadahPointsDeducted.
  ///
  /// In ar, this message translates to:
  /// **'خصم النقاط: {points}'**
  String manageIbadahPointsDeducted(String points);

  /// No description provided for @manageIbadahDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get manageIbadahDeleteConfirmTitle;

  /// No description provided for @manageIbadahDeleteConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف \"{name}\"؟'**
  String manageIbadahDeleteConfirmBody(String name);

  /// No description provided for @manageIbadahCancelButton.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get manageIbadahCancelButton;

  /// No description provided for @manageIbadahDeleteButton.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get manageIbadahDeleteButton;

  /// No description provided for @manageIbadahDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم الحذف بنجاح'**
  String get manageIbadahDeletedSuccess;

  /// No description provided for @manageIbadahDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل الحذف: {error}'**
  String manageIbadahDeleteFailed(String error);

  /// No description provided for @manageIbadahEditHabitTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العادة'**
  String get manageIbadahEditHabitTitle;

  /// No description provided for @manageIbadahEditProhibitionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المحظور'**
  String get manageIbadahEditProhibitionTitle;

  /// No description provided for @manageIbadahAddPositiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عادة إيجابية'**
  String get manageIbadahAddPositiveTitle;

  /// No description provided for @manageIbadahAddNegativeTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عادة سلبية (محظور)'**
  String get manageIbadahAddNegativeTitle;

  /// No description provided for @manageIbadahNameFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم العادة'**
  String get manageIbadahNameFieldLabel;

  /// No description provided for @manageIbadahRequiredValidation.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get manageIbadahRequiredValidation;

  /// No description provided for @manageIbadahPointsEarnedFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'النقاط التي ستكتسبها'**
  String get manageIbadahPointsEarnedFieldLabel;

  /// No description provided for @manageIbadahPointsDeductedFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'النقاط التي ستُخصم'**
  String get manageIbadahPointsDeductedFieldLabel;

  /// No description provided for @manageIbadahInvalidNumberValidation.
  ///
  /// In ar, this message translates to:
  /// **'رقم غير صحيح'**
  String get manageIbadahInvalidNumberValidation;

  /// No description provided for @manageIbadahSaveButton.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get manageIbadahSaveButton;

  /// No description provided for @manageIbadahAddButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get manageIbadahAddButton;

  /// No description provided for @manageIbadahUpdatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم التعديل بنجاح'**
  String get manageIbadahUpdatedSuccess;

  /// No description provided for @manageIbadahAddedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة بنجاح'**
  String get manageIbadahAddedSuccess;

  /// No description provided for @adhanOverlayPrayerTimeTitle.
  ///
  /// In ar, this message translates to:
  /// **'حان وقت {prayer}'**
  String adhanOverlayPrayerTimeTitle(String prayer);

  /// No description provided for @adhanOverlayCloseButton.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get adhanOverlayCloseButton;

  /// No description provided for @adhanOverlayGoToPrayerButton.
  ///
  /// In ar, this message translates to:
  /// **'الذهاب للصلاة'**
  String get adhanOverlayGoToPrayerButton;

  /// No description provided for @adhanOverlayDuaSectionLabel.
  ///
  /// In ar, this message translates to:
  /// **'دعاء ما بعد الأذان'**
  String get adhanOverlayDuaSectionLabel;

  /// No description provided for @hijriEraSuffix.
  ///
  /// In ar, this message translates to:
  /// **'هـ'**
  String get hijriEraSuffix;

  /// No description provided for @authEnterEmailPassword.
  ///
  /// In ar, this message translates to:
  /// **'أدخل البريد وكلمة المرور'**
  String get authEnterEmailPassword;

  /// No description provided for @authUnexpectedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get authUnexpectedError;

  /// No description provided for @authEnterUsername.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المستخدم'**
  String get authEnterUsername;

  /// No description provided for @authGoogleConfigIncomplete.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات Google غير مكتملة: تأكد من إضافة بصمة SHA-1 ومعرف الويب في Google Cloud Console.'**
  String get authGoogleConfigIncomplete;

  /// No description provided for @authGoogleNetworkError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بخوادم Google، تحقق من اتصالك بالإنترنت'**
  String get authGoogleNetworkError;

  /// No description provided for @authGoogleGenericError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تسجيل الدخول عبر Google، يرجى المحاولة لاحقاً'**
  String get authGoogleGenericError;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailNotConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تأكيد بريدك الإلكتروني عبر الرابط المرسل إليك أولاً'**
  String get authErrorEmailNotConfirmed;

  /// No description provided for @authErrorEmailAlreadyRegistered.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد الإلكتروني مسجل مسبقاً، يرجى تسجيل الدخول'**
  String get authErrorEmailAlreadyRegistered;

  /// No description provided for @authErrorUsernameTaken.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم مستخدم بالفعل، اختر اسماً آخر'**
  String get authErrorUsernameTaken;

  /// No description provided for @authErrorPasswordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تتكون من 6 خانات على الأقل'**
  String get authErrorPasswordTooShort;

  /// No description provided for @authErrorRateLimit.
  ///
  /// In ar, this message translates to:
  /// **'تجاوزت عدد المحاولات المسموح بها، يرجى الانتظار قليلاً'**
  String get authErrorRateLimit;

  /// No description provided for @authErrorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'فشل الاتصال، تحقق من اتصالك بالإنترنت'**
  String get authErrorNetwork;

  /// No description provided for @authErrorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في عملية التسجيل، يرجى المحاولة لاحقاً'**
  String get authErrorGeneric;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'متابعة كضيف — استكشف التطبيق ➜'**
  String get authContinueAsGuest;

  /// No description provided for @authSignInTab.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authSignInTab;

  /// No description provided for @authSignUpTab.
  ///
  /// In ar, this message translates to:
  /// **'حساب جديد'**
  String get authSignUpTab;

  /// No description provided for @authUsernameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get authUsernameHint;

  /// No description provided for @authEmailHint.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPassword;

  /// No description provided for @authSecureSignInButton.
  ///
  /// In ar, this message translates to:
  /// **'دخول آمن'**
  String get authSecureSignInButton;

  /// No description provided for @authCreateAccountButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get authCreateAccountButton;

  /// No description provided for @authOrSeparator.
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get authOrSeparator;

  /// No description provided for @authGoogleSignInButton.
  ///
  /// In ar, this message translates to:
  /// **'الدخول عبر Google'**
  String get authGoogleSignInButton;

  /// No description provided for @authTagline.
  ///
  /// In ar, this message translates to:
  /// **'رفيقك في محاسبة النفس والطاعات'**
  String get authTagline;

  /// No description provided for @bottomNavHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get bottomNavHome;

  /// No description provided for @bottomNavQiyam.
  ///
  /// In ar, this message translates to:
  /// **'قيام'**
  String get bottomNavQiyam;

  /// No description provided for @bottomNavMuhasaba.
  ///
  /// In ar, this message translates to:
  /// **'المحاسبة'**
  String get bottomNavMuhasaba;

  /// No description provided for @bottomNavStatistics.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات'**
  String get bottomNavStatistics;

  /// No description provided for @bottomNavAsma.
  ///
  /// In ar, this message translates to:
  /// **'أسماء الله'**
  String get bottomNavAsma;

  /// No description provided for @bottomNavSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get bottomNavSettings;

  /// No description provided for @settingEnabled.
  ///
  /// In ar, this message translates to:
  /// **'مفعل'**
  String get settingEnabled;

  /// No description provided for @settingDisabled.
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get settingDisabled;

  /// No description provided for @syncStatusSyncing.
  ///
  /// In ar, this message translates to:
  /// **'جاري المزامنة...'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة بنجاح'**
  String get syncStatusSuccess;

  /// No description provided for @overlaySettingsSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار والإشعارات'**
  String get overlaySettingsSectionTitle;

  /// No description provided for @overlaySettingAdhanScreenLabel.
  ///
  /// In ar, this message translates to:
  /// **'شاشة الأذان التلقائية'**
  String get overlaySettingAdhanScreenLabel;

  /// No description provided for @overlaySettingAdhanScreenSublabel.
  ///
  /// In ar, this message translates to:
  /// **'يُظهر شاشة الأذان عند دخول وقت الصلاة'**
  String get overlaySettingAdhanScreenSublabel;

  /// No description provided for @overlaySettingAdhanSoundLabel.
  ///
  /// In ar, this message translates to:
  /// **'صوت الأذان'**
  String get overlaySettingAdhanSoundLabel;

  /// No description provided for @overlaySettingAdhanSoundSublabel.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل صوت الأذان تلقائياً عند دخول الوقت'**
  String get overlaySettingAdhanSoundSublabel;

  /// No description provided for @overlaySettingPopupsLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوافذ الأذكار والأدعية'**
  String get overlaySettingPopupsLabel;

  /// No description provided for @overlaySettingPopupsSublabel.
  ///
  /// In ar, this message translates to:
  /// **'يُظهر أذكاراً وأدعيةً بشكل منبثق على الشاشة'**
  String get overlaySettingPopupsSublabel;

  /// No description provided for @overlaySettingIntervalHeader.
  ///
  /// In ar, this message translates to:
  /// **'معدل ظهور الأذكار'**
  String get overlaySettingIntervalHeader;

  /// No description provided for @overlaySettingInterval15Min.
  ///
  /// In ar, this message translates to:
  /// **'كل 15 دقيقة (~96/يوم)'**
  String get overlaySettingInterval15Min;

  /// No description provided for @overlaySettingInterval20Min.
  ///
  /// In ar, this message translates to:
  /// **'كل 20 دقيقة (~72/يوم)'**
  String get overlaySettingInterval20Min;

  /// No description provided for @overlaySettingInterval24Min.
  ///
  /// In ar, this message translates to:
  /// **'كل 24 دقيقة (~60/يوم)'**
  String get overlaySettingInterval24Min;

  /// No description provided for @overlaySettingInterval30Min.
  ///
  /// In ar, this message translates to:
  /// **'كل 30 دقيقة (~48/يوم)'**
  String get overlaySettingInterval30Min;

  /// No description provided for @overlaySettingInterval1Hour.
  ///
  /// In ar, this message translates to:
  /// **'كل ساعة (~24/يوم)'**
  String get overlaySettingInterval1Hour;

  /// No description provided for @overlaySettingInterval2Hours.
  ///
  /// In ar, this message translates to:
  /// **'كل ساعتين (~12/يوم)'**
  String get overlaySettingInterval2Hours;

  /// Daily count estimate for popup windows
  ///
  /// In ar, this message translates to:
  /// **'ستظهر النوافذ ~{count} مرة يومياً'**
  String overlaySettingDailyCount(int count);
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
