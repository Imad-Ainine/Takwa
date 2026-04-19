// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$DailyRecordDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyRecordsTable get dailyRecords => attachedDatabase.dailyRecords;
  $ProhibitionsLogTable get prohibitionsLog => attachedDatabase.prohibitionsLog;
  $CustomIbadahTable get customIbadah => attachedDatabase.customIbadah;
  $CustomIbadahLogTable get customIbadahLog => attachedDatabase.customIbadahLog;
}
mixin _$StatsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyRecordsTable get dailyRecords => attachedDatabase.dailyRecords;
  $ProhibitionsLogTable get prohibitionsLog => attachedDatabase.prohibitionsLog;
  $AchievementsTable get achievements => attachedDatabase.achievements;
}
mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserSettingsTable get userSettings => attachedDatabase.userSettings;
}
mixin _$RemindersDaoMixin on DatabaseAccessor<AppDatabase> {
  $RemindersTable get reminders => attachedDatabase.reminders;
}
