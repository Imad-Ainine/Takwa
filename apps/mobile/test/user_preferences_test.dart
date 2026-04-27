import 'package:flutter_test/flutter_test.dart';
import 'package:takwa/features/settings/data/user_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  group('UserPreferences Serialization', () {
    test('toMap and fromMap should be consistent', () {
      const prefs = UserPreferences(
        madhab: 'hanafi',
        calcMethod: 'MWL',
        language: 'ar',
        prayerReminder: true,
        preAdhanNotif: true,
        iqamaNotif: false,
        wakeUpBeforeFajr: true,
        wakeUpTime: TimeOfDay(hour: 4, minute: 30),
        morningAdhkarReminder: true,
        eveningAdhkarReminder: true,
        adhkarNotifEnabled: true,
        morningAdhkarTime: TimeOfDay(hour: 6, minute: 0),
        eveningAdhkarTime: TimeOfDay(hour: 17, minute: 0),
        sleepAdhkarTime: TimeOfDay(hour: 22, minute: 0),
        afterFajrAdhkar: true,
        afterAsrAdhkar: true,
        muhasabaReminder: false,
        muhasabaTime: TimeOfDay(hour: 21, minute: 0),
        dailyDuasOn: true,
        specialRemindersOn: true,
        fastingRemindersOn: true,
        ramadanMode: false,
        themeMode: 'dark',
        adhanSound: 'adhan_makkat.mp3',
        overlayEnabled: true,
        adhanSoundEnabled: true,
        adhanScreenEnabled: true,
        popupIntervalMins: 15,
        adhanMode: 'sound',
        adhanVolumeLevel: 0.8,
        silentModeEnabled: true,
        silentDurationMins: 25,
        silentModeAlertStyle: 'vibrate',
        silentVibrationEnabled: true,
        autoSilentAfterAdhan: true,
        adhanInSilentEnabled: true,
        notifsInSilentEnabled: false,
        flipToSilenceEnabled: true,
        wakeScreenEnabled: true,
        vibrateWithAdhan: true,
        adhanAlarmEnabled: true,
      );

      final map = prefs.toMap();
      final fromMap = UserPreferences.fromMap(map);

      expect(fromMap.madhab, prefs.madhab);
      expect(fromMap.calcMethod, prefs.calcMethod);
      expect(fromMap.adhanMode, prefs.adhanMode);
      expect(fromMap.adhanVolumeLevel, prefs.adhanVolumeLevel);
      expect(fromMap.silentModeEnabled, prefs.silentModeEnabled);
      expect(fromMap.silentDurationMins, prefs.silentDurationMins);
      expect(fromMap.autoSilentAfterAdhan, prefs.autoSilentAfterAdhan);
      expect(fromMap.wakeUpTime.hour, prefs.wakeUpTime.hour);
      expect(fromMap.wakeUpTime.minute, prefs.wakeUpTime.minute);
    });

    test('fromMap should handle missing keys with defaults', () {
      final map = {'madhab': 'shafi', 'calc_method': 'ISNA'};

      final prefs = UserPreferences.fromMap(map);

      expect(prefs.madhab, 'shafi');
      expect(prefs.calcMethod, 'ISNA');
      expect(prefs.silentDurationMins, 20); // Default
      expect(prefs.adhanMode, 'sound'); // Default
    });
  });
}
