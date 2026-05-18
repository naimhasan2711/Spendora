import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/settings_model.dart';
import '../../../core/services/hive_service.dart';

/// Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) => SettingsNotifier(),
);

/// Settings Notifier
class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(HiveService.instance.settings);

  /// Update theme mode
  Future<void> setThemeMode(int themeModeIndex) async {
    state = state.copyWith(themeModeIndex: themeModeIndex);
    await _saveSettings();
  }

  /// Update default currency
  Future<void> setDefaultCurrency(String currencyCode) async {
    state = state.copyWith(defaultCurrency: currencyCode);
    await _saveSettings();
  }

  /// Update default account
  Future<void> setDefaultAccount(String accountId) async {
    state = state.copyWith(defaultAccountId: accountId);
    await _saveSettings();
  }

  /// Enable/disable PIN
  Future<void> setPinEnabled(bool enabled, {String? pinCode}) async {
    state = state.copyWith(
      pinEnabled: enabled,
      pinCode: pinCode,
    );
    await _saveSettings();
  }

  /// Update PIN code
  Future<void> updatePinCode(String pinCode) async {
    state = state.copyWith(pinCode: pinCode);
    await _saveSettings();
  }

  /// Enable/disable biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    state = state.copyWith(biometricEnabled: enabled);
    await _saveSettings();
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    state = state.copyWith(
      onboardingComplete: true,
      firstLaunch: false,
    );
    await _saveSettings();
  }

  /// Update date format
  Future<void> setDateFormat(String format) async {
    state = state.copyWith(dateFormat: format);
    await _saveSettings();
  }

  /// Update time format
  Future<void> setTimeFormat(String format) async {
    state = state.copyWith(timeFormat: format);
    await _saveSettings();
  }

  /// Update week start day
  Future<void> setWeekStartDay(int day) async {
    state = state.copyWith(weekStartDay: day);
    await _saveSettings();
  }

  /// Update show cents
  Future<void> setShowCents(bool show) async {
    state = state.copyWith(showCents: show);
    await _saveSettings();
  }

  /// Update haptic feedback
  Future<void> setHapticFeedback(bool enabled) async {
    state = state.copyWith(hapticFeedback: enabled);
    await _saveSettings();
  }

  /// Update last backup date
  Future<void> setLastBackupDate(DateTime date) async {
    state = state.copyWith(lastBackupDate: date);
    await _saveSettings();
  }

  /// Update language
  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }

  /// Update user name
  Future<void> setUserName(String name) async {
    state = state.copyWith(userName: name);
    await _saveSettings();
  }

  /// Update user profile image path
  Future<void> setUserImagePath(String? imagePath) async {
    state = state.copyWith(userImagePath: imagePath);
    await _saveSettings();
  }

  /// Verify PIN
  bool verifyPin(String pin) {
    return state.pinCode == pin;
  }

  /// Save settings to Hive
  Future<void> _saveSettings() async {
    await HiveService.instance.updateSettings(state);
  }
}
