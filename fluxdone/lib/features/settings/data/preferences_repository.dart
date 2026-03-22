import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PreferencesRepository {
  final SharedPreferences _prefs;

  PreferencesRepository(this._prefs);

  static const String _keyAppTheme = 'app_theme';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyDefaultReminderOffset = 'default_reminder_offset';
  static const String _keyNotificationSound = 'notification_sound';
  static const String _keyGoogleCalendarConnected = 'google_calendar_connected';
  static const String _keyLastBackupTimestamp = 'last_backup_timestamp';
  static const String _keyDriveBackupFolderId = 'drive_backup_folder_id';
  static const String _keyCalendarLastViewMode = 'calendar_last_view_mode';

  // Theme
  String getAppTheme() => _prefs.getString(_keyAppTheme) ?? 'system';
  Future<void> setAppTheme(String theme) => _prefs.setString(_keyAppTheme, theme);

  // Notifications
  bool areNotificationsEnabled() => _prefs.getBool(_keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool enabled) => _prefs.setBool(_keyNotificationsEnabled, enabled);

  int getDefaultReminderOffset() => _prefs.getInt(_keyDefaultReminderOffset) ?? 0;
  Future<void> setDefaultReminderOffset(int offset) => _prefs.setInt(_keyDefaultReminderOffset, offset);

  String getNotificationSound() => _prefs.getString(_keyNotificationSound) ?? 'default';
  Future<void> setNotificationSound(String sound) => _prefs.setString(_keyNotificationSound, sound);

  // Google Integration
  bool isGoogleCalendarConnected() => _prefs.getBool(_keyGoogleCalendarConnected) ?? false;
  Future<void> setGoogleCalendarConnected(bool connected) => _prefs.setBool(_keyGoogleCalendarConnected, connected);

  int? getLastBackupTimestamp() => _prefs.getInt(_keyLastBackupTimestamp);
  Future<void> setLastBackupTimestamp(int timestamp) => _prefs.setInt(_keyLastBackupTimestamp, timestamp);

  String? getDriveBackupFolderId() => _prefs.getString(_keyDriveBackupFolderId);
  Future<void> setDriveBackupFolderId(String folderId) => _prefs.setString(_keyDriveBackupFolderId, folderId);

  // Calendar
  String getCalendarLastViewMode() => _prefs.getString(_keyCalendarLastViewMode) ?? 'day';
  Future<void> setCalendarLastViewMode(String mode) => _prefs.setString(_keyCalendarLastViewMode, mode);

  // Folder Expansion (Dynamic keys)
  bool isFolderExpanded(int folderId) => _prefs.getBool('folder_${folderId}_expanded') ?? true;
  Future<void> setFolderExpanded(int folderId, bool expanded) => _prefs.setBool('folder_${folderId}_expanded', expanded);
}
