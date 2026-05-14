import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';

class StorageSettingsService {
  static const String _settingsBoxName = 'storage_settings';
  static const String _backupLocationKey = 'backup_location';
  static const String _autoBackupFrequencyKey = 'auto_backup_frequency';

  // Auto backup frequency options
  static const String frequencyNone = 'none';
  static const String frequencyDaily = 'daily';
  static const String frequency3Days = '3days';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyMonthly = 'monthly';

  /// Initialize settings box
  static Future<void> initializeSettings() async {
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      await Hive.openBox<String>(_settingsBoxName);
    }
  }

  /// Get backup location
  /// Returns default Documents path if not set
  static Future<String> getBackupLocation() async {
    await initializeSettings();
    final box = Hive.box<String>(_settingsBoxName);
    String? location = box.get(_backupLocationKey);

    if (location == null || location.isEmpty) {
      // Set default location
      location = await _getDefaultBackupLocation();
      await box.put(_backupLocationKey, location);
    }

    return location;
  }

  /// Set custom backup location
  static Future<void> setBackupLocation(String path) async {
    await initializeSettings();
    final box = Hive.box<String>(_settingsBoxName);
    await box.put(_backupLocationKey, path);
  }

  /// Get auto backup frequency
  /// Returns 'none' if not set
  static Future<String> getAutoBackupFrequency() async {
    await initializeSettings();
    final box = Hive.box<String>(_settingsBoxName);
    return box.get(_autoBackupFrequencyKey) ?? frequencyNone;
  }

  /// Set auto backup frequency
  static Future<void> setAutoBackupFrequency(String frequency) async {
    await initializeSettings();
    final box = Hive.box<String>(_settingsBoxName);
    await box.put(_autoBackupFrequencyKey, frequency);
  }

  /// Get human-readable backup frequency label
  static String getFrequencyLabel(String frequency) {
    switch (frequency) {
      case frequencyDaily:
        return 'Tiap hari';
      case frequency3Days:
        return 'Tiap 3 hari';
      case frequencyWeekly:
        return 'Tiap minggu';
      case frequencyMonthly:
        return 'Tiap bulan';
      case frequencyNone:
      default:
        return 'Matikan';
    }
  }

  /// Get default backup location
  /// For Android: /storage/emulated/0/Documents
  static Future<String> _getDefaultBackupLocation() async {
    try {
      if (Platform.isAndroid) {
        // Android default Documents path
        return '/storage/emulated/0/Documents/Suinime_Backups';
      } else if (Platform.isIOS) {
        // iOS documents directory
        return '${Directory.systemTemp.path}/Suinime_Backups';
      } else {
        // Default for other platforms
        return '${Directory.systemTemp.path}/Suinime_Backups';
      }
    } catch (e) {
      return '${Directory.systemTemp.path}/Suinime_Backups';
    }
  }

  /// Clear all settings
  static Future<void> clearSettings() async {
    await initializeSettings();
    final box = Hive.box<String>(_settingsBoxName);
    await box.clear();
  }
}
