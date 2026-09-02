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
