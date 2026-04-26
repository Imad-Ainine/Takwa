import 'package:flutter/material.dart';

class UserPreferences {
  final String madhab;
  final String calcMethod;
  final String language;

  final bool prayerReminder;
  final bool preAdhanNotif;
  final bool iqamaNotif;

  final bool wakeUpBeforeFajr;
  final TimeOfDay wakeUpTime;

  final bool morningAdhkarReminder;
  final bool eveningAdhkarReminder;

  final bool adhkarNotifEnabled;
  final TimeOfDay morningAdhkarTime;
  final TimeOfDay eveningAdhkarTime;
  final TimeOfDay sleepAdhkarTime;
  final bool afterFajrAdhkar;
  final bool afterAsrAdhkar;

  final bool muhasabaReminder;
  final TimeOfDay muhasabaTime;

  final bool dailyDuasOn;
  final bool specialRemindersOn;
  final bool fastingRemindersOn;

  final bool ramadanMode;
  final String themeMode; // "system", "light", "dark"
  final String adhanSound;

  const UserPreferences({
    this.madhab = 'shafi',
    this.calcMethod = 'MWL',
    this.language = 'ar',

    this.prayerReminder = true,
    this.preAdhanNotif = true,
    this.iqamaNotif = true,

    this.wakeUpBeforeFajr = false,
    this.wakeUpTime = const TimeOfDay(hour: 4, minute: 30),

    this.morningAdhkarReminder = true,
    this.eveningAdhkarReminder = true,

    this.adhkarNotifEnabled = true,
    this.morningAdhkarTime = const TimeOfDay(hour: 6, minute: 30),
    this.eveningAdhkarTime = const TimeOfDay(hour: 17, minute: 0),
    this.sleepAdhkarTime = const TimeOfDay(hour: 22, minute: 0),
    this.afterFajrAdhkar = true,
    this.afterAsrAdhkar = true,

    this.muhasabaReminder = true,
    this.muhasabaTime = const TimeOfDay(hour: 21, minute: 0),

    this.dailyDuasOn = true,
    this.specialRemindersOn = true,
    this.fastingRemindersOn = true,

    this.ramadanMode = false,
    this.themeMode = 'system',
    this.adhanSound = 'Adhan-Makkah.mp3',
  });

  UserPreferences copyWith({
    String? madhab,
    String? calcMethod,
    String? language,
    bool? prayerReminder,
    bool? preAdhanNotif,
    bool? iqamaNotif,
    bool? wakeUpBeforeFajr,
    TimeOfDay? wakeUpTime,
    bool? morningAdhkarReminder,
    bool? eveningAdhkarReminder,
    bool? adhkarNotifEnabled,
    TimeOfDay? morningAdhkarTime,
    TimeOfDay? eveningAdhkarTime,
    TimeOfDay? sleepAdhkarTime,
    bool? afterFajrAdhkar,
    bool? afterAsrAdhkar,
    bool? muhasabaReminder,
    TimeOfDay? muhasabaTime,
    bool? dailyDuasOn,
    bool? specialRemindersOn,
    bool? fastingRemindersOn,
    bool? ramadanMode,
    String? themeMode,
    String? adhanSound,
  }) {
    return UserPreferences(
      madhab: madhab ?? this.madhab,
      calcMethod: calcMethod ?? this.calcMethod,
      language: language ?? this.language,
      prayerReminder: prayerReminder ?? this.prayerReminder,
      preAdhanNotif: preAdhanNotif ?? this.preAdhanNotif,
      iqamaNotif: iqamaNotif ?? this.iqamaNotif,
      wakeUpBeforeFajr: wakeUpBeforeFajr ?? this.wakeUpBeforeFajr,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      morningAdhkarReminder:
          morningAdhkarReminder ?? this.morningAdhkarReminder,
      eveningAdhkarReminder:
          eveningAdhkarReminder ?? this.eveningAdhkarReminder,
      adhkarNotifEnabled: adhkarNotifEnabled ?? this.adhkarNotifEnabled,
      morningAdhkarTime: morningAdhkarTime ?? this.morningAdhkarTime,
      eveningAdhkarTime: eveningAdhkarTime ?? this.eveningAdhkarTime,
      sleepAdhkarTime: sleepAdhkarTime ?? this.sleepAdhkarTime,
      afterFajrAdhkar: afterFajrAdhkar ?? this.afterFajrAdhkar,
      afterAsrAdhkar: afterAsrAdhkar ?? this.afterAsrAdhkar,
      muhasabaReminder: muhasabaReminder ?? this.muhasabaReminder,
      muhasabaTime: muhasabaTime ?? this.muhasabaTime,
      dailyDuasOn: dailyDuasOn ?? this.dailyDuasOn,
      specialRemindersOn: specialRemindersOn ?? this.specialRemindersOn,
      fastingRemindersOn: fastingRemindersOn ?? this.fastingRemindersOn,
      ramadanMode: ramadanMode ?? this.ramadanMode,
      themeMode: themeMode ?? this.themeMode,
      adhanSound: adhanSound ?? this.adhanSound,
    );
  }

  /// Maps exactly to Supabase column names
  Map<String, dynamic> toMap() {
    return {
      'madhab': madhab,
      'calc_method': calcMethod,
      'language': language,
      'prayer_reminder': prayerReminder,
      'pre_adhan_notif': preAdhanNotif,
      'iqama_notif': iqamaNotif,
      'wake_up_before_fajr': wakeUpBeforeFajr,
      'wake_up_time':
          '${wakeUpTime.hour.toString().padLeft(2, '0')}:${wakeUpTime.minute.toString().padLeft(2, '0')}',
      'morning_adhkar_reminder': morningAdhkarReminder,
      'evening_adhkar_reminder': eveningAdhkarReminder,
      'adhkar_notif_enabled': adhkarNotifEnabled,
      'morning_adhkar_time':
          '${morningAdhkarTime.hour.toString().padLeft(2, '0')}:${morningAdhkarTime.minute.toString().padLeft(2, '0')}',
      'evening_adhkar_time':
          '${eveningAdhkarTime.hour.toString().padLeft(2, '0')}:${eveningAdhkarTime.minute.toString().padLeft(2, '0')}',
      'sleep_adhkar_time':
          '${sleepAdhkarTime.hour.toString().padLeft(2, '0')}:${sleepAdhkarTime.minute.toString().padLeft(2, '0')}',
      'after_fajr_adhkar': afterFajrAdhkar,
      'after_asr_adhkar': afterAsrAdhkar,
      'muhasaba_reminder': muhasabaReminder,
      'evening_reminder_time':
          '${muhasabaTime.hour.toString().padLeft(2, '0')}:${muhasabaTime.minute.toString().padLeft(2, '0')}',
      'daily_duas_on': dailyDuasOn,
      'special_reminders_on': specialRemindersOn,
      'fasting_reminders_on': fastingRemindersOn,
      'ramadan_mode': ramadanMode,
      'theme_mode': themeMode,
      'adhan_sound': adhanSound,
    };
  }

  /// Expects a map with Supabase column names (snake_case) or local string keys
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    // Helper to parse bool from DB or strings (SQLite)
    bool parseBool(dynamic val, {bool defaultVal = false}) {
      if (val == null) return defaultVal;
      if (val is bool) return val;
      if (val is String) {
        return val.toLowerCase() == 'true' || val == '1';
      }
      if (val is int) return val == 1;
      return defaultVal;
    }

    // Helper to parse TimeOfDay
    TimeOfDay parseTime(dynamic val, {required TimeOfDay defaultVal}) {
      if (val == null || val is! String || !val.contains(':')) {
        return defaultVal;
      }
      final parts = val.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
      return defaultVal;
    }

    return UserPreferences(
      madhab: map['madhab'] as String? ?? 'shafi',
      calcMethod: (map['calc_method'] ?? map['calcMethod']) as String? ?? 'MWL',
      language: map['language'] as String? ?? 'ar',

      prayerReminder: parseBool(
        map['prayer_reminder'] ?? map['prayerReminder'],
        defaultVal: true,
      ),
      preAdhanNotif: parseBool(
        map['pre_adhan_notif'] ?? map['preAdhanNotif'],
        defaultVal: true,
      ),
      iqamaNotif: parseBool(
        map['iqama_notif'] ?? map['iqamaNotif'],
        defaultVal: true,
      ),

      wakeUpBeforeFajr: parseBool(
        map['wake_up_before_fajr'] ?? map['wakeUpBeforeFajr'],
        defaultVal: false,
      ),
      wakeUpTime: parseTime(
        map['wake_up_time'] ?? map['wakeUpTime'],
        defaultVal: const TimeOfDay(hour: 4, minute: 30),
      ),

      morningAdhkarReminder: parseBool(
        map['morning_adhkar_reminder'] ?? map['morningAdhkarReminder'],
        defaultVal: true,
      ),
      eveningAdhkarReminder: parseBool(
        map['evening_adhkar_reminder'] ?? map['eveningAdhkarReminder'],
        defaultVal: true,
      ),

      adhkarNotifEnabled: parseBool(
        map['adhkar_notif_enabled'] ?? map['adhkarNotifEnabled'],
        defaultVal: true,
      ),
      morningAdhkarTime: parseTime(
        map['morning_adhkar_time'] ?? map['morningAdhkarTime'],
        defaultVal: const TimeOfDay(hour: 6, minute: 30),
      ),
      eveningAdhkarTime: parseTime(
        map['evening_adhkar_time'] ?? map['eveningAdhkarTime'],
        defaultVal: const TimeOfDay(hour: 17, minute: 0),
      ),
      sleepAdhkarTime: parseTime(
        map['sleep_adhkar_time'] ?? map['sleepAdhkarTime'],
        defaultVal: const TimeOfDay(hour: 22, minute: 0),
      ),
      afterFajrAdhkar: parseBool(
        map['after_fajr_adhkar'] ?? map['afterFajrAdhkar'],
        defaultVal: true,
      ),
      afterAsrAdhkar: parseBool(
        map['after_asr_adhkar'] ?? map['afterAsrAdhkar'],
        defaultVal: true,
      ),

      muhasabaReminder: parseBool(
        map['muhasaba_reminder'] ?? map['eveningMuhasabaReminder'],
        defaultVal: true,
      ),
      muhasabaTime: parseTime(
        map['evening_reminder_time'] ?? map['eveningReminderTime'],
        defaultVal: const TimeOfDay(hour: 21, minute: 0),
      ),

      dailyDuasOn: parseBool(
        map['daily_duas_on'] ?? map['dailyDuasOn'],
        defaultVal: true,
      ),
      specialRemindersOn: parseBool(
        map['special_reminders_on'] ?? map['specialRemindersOn'],
        defaultVal: true,
      ),
      fastingRemindersOn: parseBool(
        map['fasting_reminders_on'] ?? map['fastingRemindersOn'],
        defaultVal: true,
      ),

      ramadanMode: parseBool(
        map['ramadan_mode'] ?? map['ramadanMode'],
        defaultVal: false,
      ),
      themeMode:
          map['theme_mode'] as String? ??
          map['themeMode'] as String? ??
          'system',
      adhanSound: map['adhan_sound'] as String? ?? map['adhanSound'] as String? ?? 'Adhan-Makkah.mp3',
    );
  }
}
