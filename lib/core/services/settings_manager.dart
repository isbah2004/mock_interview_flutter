import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SettingsManager {
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _soundKey = 'sound';
  static const String _vibrationKey = 'vibration';
  static const String _darkModeKey = 'dark_mode';
  static const String _voiceRecordingQualityKey = 'voice_recording_quality';
  static const String _autoSaveRecordingsKey = 'auto_save_recordings';
  static const String _languageKey = 'language';
  static const String _notificationTimeKey = 'notification_time';

  static GetStorage get _storage => GetStorage();

  /// Initialize GetStorage (call this in main.dart before runApp)
  static Future<void> init() async {
    await GetStorage.init();
  }

  /// Get all user settings
  static Map<String, dynamic> getAllSettings() {
    return {
      'pushNotifications': _storage.read(_pushNotificationsKey) ?? true,
      'sound': _storage.read(_soundKey) ?? true,
      'vibration': _storage.read(_vibrationKey) ?? false,
      'darkMode': _storage.read(_darkModeKey) ?? false,
      'voiceRecordingQuality': _storage.read(_voiceRecordingQualityKey) ?? true,
      'autoSaveRecordings': _storage.read(_autoSaveRecordingsKey) ?? true,
      'language': _storage.read(_languageKey) ?? 'en',
      'notificationTime': _storage.read(_notificationTimeKey) ?? '18:00',
    };
  }

  /// Notification Settings
  static bool getPushNotifications() {
    return _storage.read(_pushNotificationsKey) ?? true;
  }

  static Future<void> setPushNotifications(bool value) async {
    await _storage.write(_pushNotificationsKey, value);
  }

  static bool getSound() {
    return _storage.read(_soundKey) ?? true;
  }

  static Future<void> setSound(bool value) async {
    await _storage.write(_soundKey, value);
  }

  static bool getVibration() {
    return _storage.read(_vibrationKey) ?? false;
  }

  static Future<void> setVibration(bool value) async {
    await _storage.write(_vibrationKey, value);
  }

  /// Appearance Settings
  static bool getDarkMode() {
    return _storage.read(_darkModeKey) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    await _storage.write(_darkModeKey, value);
  }

  /// Audio Settings
  static bool getVoiceRecordingQuality() {
    return _storage.read(_voiceRecordingQualityKey) ?? true;
  }

  static Future<void> setVoiceRecordingQuality(bool value) async {
    await _storage.write(_voiceRecordingQualityKey, value);
  }

  static bool getAutoSaveRecordings() {
    return _storage.read(_autoSaveRecordingsKey) ?? true;
  }

  static Future<void> setAutoSaveRecordings(bool value) async {
    await _storage.write(_autoSaveRecordingsKey, value);
  }

  /// Language Settings
  static String getLanguage() {
    return _storage.read(_languageKey) ?? 'en';
  }

  static Future<void> setLanguage(String value) async {
    await _storage.write(_languageKey, value);
  }

  /// Notification Time Settings
  static String getNotificationTime() {
    return _storage.read(_notificationTimeKey) ?? '18:00';
  }

  static Future<void> setNotificationTime(String value) async {
    await _storage.write(_notificationTimeKey, value);
  }

  /// Reset all settings to defaults
  static Future<void> resetToDefaults() async {
    await _storage.erase();
  }

  /// Export settings as JSON for backup
  static Map<String, dynamic> exportSettings() {
    return getAllSettings();
  }

  /// Import settings from JSON for restore
  static Future<void> importSettings(Map<String, dynamic> settings) async {
    for (String key in settings.keys) {
      final value = settings[key];
      final storageKey = _getStorageKey(key);
      await _storage.write(storageKey, value);
    }
  }

  static String _getStorageKey(String settingKey) {
    switch (settingKey) {
      case 'pushNotifications':
        return _pushNotificationsKey;
      case 'sound':
        return _soundKey;
      case 'vibration':
        return _vibrationKey;
      case 'darkMode':
        return _darkModeKey;
      case 'voiceRecordingQuality':
        return _voiceRecordingQualityKey;
      case 'autoSaveRecordings':
        return _autoSaveRecordingsKey;
      case 'language':
        return _languageKey;
      case 'notificationTime':
        return _notificationTimeKey;
      default:
        return settingKey;
    }
  }

  /// Theme-related helpers
  static ThemeMode getThemeMode(bool isDarkMode) {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// Privacy and Security helpers
  static bool isBiometricEnabled() {
    return _storage.read('biometric_enabled') ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write('biometric_enabled', enabled);
  }

  static bool isAnalyticsEnabled() {
    return _storage.read('analytics_enabled') ?? true;
  }

  static Future<void> setAnalyticsEnabled(bool enabled) async {
    await _storage.write('analytics_enabled', enabled);
  }

  /// Interview-specific settings
  static String getDefaultInterviewDifficulty() {
    return _storage.read('default_difficulty') ?? 'medium';
  }

  static Future<void> setDefaultInterviewDifficulty(String difficulty) async {
    await _storage.write('default_difficulty', difficulty);
  }

  static String getDefaultInterviewCategory() {
    return _storage.read('default_category') ?? 'technical';
  }

  static Future<void> setDefaultInterviewCategory(String category) async {
    await _storage.write('default_category', category);
  }

  static int getSessionReminderMinutes() {
    return _storage.read('session_reminder_minutes') ?? 30;
  }

  static Future<void> setSessionReminderMinutes(int minutes) async {
    await _storage.write('session_reminder_minutes', minutes);
  }
}
