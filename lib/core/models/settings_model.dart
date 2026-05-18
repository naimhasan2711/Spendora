import 'package:flutter/material.dart';

/// App Settings Model
class SettingsModel {
  final int themeModeIndex; // 0: system, 1: light, 2: dark
  final String defaultCurrency;
  final String defaultAccountId;
  final bool pinEnabled;
  final String? pinCode;
  final bool biometricEnabled;
  final bool onboardingComplete;
  final bool firstLaunch;
  final String dateFormat;
  final String timeFormat;
  final int weekStartDay; // 0: Sunday, 1: Monday, etc.
  final bool showCents;
  final bool hapticFeedback;
  final DateTime? lastBackupDate;
  final String language;
  // User Profile fields
  final String userName;
  final String? userImagePath;

  SettingsModel({
    this.themeModeIndex = 0,
    this.defaultCurrency = 'BDT',
    this.defaultAccountId = 'cash',
    this.pinEnabled = false,
    this.pinCode,
    this.biometricEnabled = false,
    this.onboardingComplete = false,
    this.firstLaunch = true,
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = 'hh:mm a',
    this.weekStartDay = 0,
    this.showCents = true,
    this.hapticFeedback = true,
    this.lastBackupDate,
    this.language = 'en',
    this.userName = 'User',
    this.userImagePath,
  });

  ThemeMode get themeMode {
    switch (themeModeIndex) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Verify PIN code
  bool verifyPin(String pin) {
    return pinCode != null && pinCode == pin;
  }

  SettingsModel copyWith({
    int? themeModeIndex,
    String? defaultCurrency,
    String? defaultAccountId,
    bool? pinEnabled,
    String? pinCode,
    bool? biometricEnabled,
    bool? onboardingComplete,
    bool? firstLaunch,
    String? dateFormat,
    String? timeFormat,
    int? weekStartDay,
    bool? showCents,
    bool? hapticFeedback,
    DateTime? lastBackupDate,
    String? language,
    String? userName,
    String? userImagePath,
  }) {
    return SettingsModel(
      themeModeIndex: themeModeIndex ?? this.themeModeIndex,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      pinCode: pinCode ?? this.pinCode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      firstLaunch: firstLaunch ?? this.firstLaunch,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      showCents: showCents ?? this.showCents,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      language: language ?? this.language,
      userName: userName ?? this.userName,
      userImagePath: userImagePath ?? this.userImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeModeIndex': themeModeIndex,
      'defaultCurrency': defaultCurrency,
      'defaultAccountId': defaultAccountId,
      'pinEnabled': pinEnabled,
      'pinCode': pinCode,
      'biometricEnabled': biometricEnabled,
      'onboardingComplete': onboardingComplete,
      'firstLaunch': firstLaunch,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'weekStartDay': weekStartDay,
      'showCents': showCents,
      'hapticFeedback': hapticFeedback,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
      'language': language,
      'userName': userName,
      'userImagePath': userImagePath,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeModeIndex: json['themeModeIndex'] as int? ?? 0,
      defaultCurrency: json['defaultCurrency'] as String? ?? 'BDT',
      defaultAccountId: json['defaultAccountId'] as String? ?? 'cash',
      pinEnabled: json['pinEnabled'] as bool? ?? false,
      pinCode: json['pinCode'] as String?,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      firstLaunch: json['firstLaunch'] as bool? ?? true,
      dateFormat: json['dateFormat'] as String? ?? 'dd/MM/yyyy',
      timeFormat: json['timeFormat'] as String? ?? 'hh:mm a',
      weekStartDay: json['weekStartDay'] as int? ?? 0,
      showCents: json['showCents'] as bool? ?? true,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'] as String)
          : null,
      language: json['language'] as String? ?? 'en',
      userName: json['userName'] as String? ?? 'User',
      userImagePath: json['userImagePath'] as String?,
    );
  }
}
