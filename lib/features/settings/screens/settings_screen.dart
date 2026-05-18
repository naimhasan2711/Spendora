import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/settings_model.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

/// Settings Screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance
          const _SectionHeader(title: 'Appearance'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: _getThemeName(settings.themeModeIndex),
            onTap: () => _showThemeDialog(context, ref, settings),
          ),

          // Regional
          const _SectionHeader(title: 'Regional'),
          _SettingsTile(
            icon: Icons.attach_money_rounded,
            title: 'Currency',
            subtitle: settings.defaultCurrency,
            onTap: () => _showCurrencyDialog(context, ref),
          ),
          _SettingsTile(
            icon: Icons.calendar_today_rounded,
            title: 'Date Format',
            subtitle: settings.dateFormat,
            onTap: () => _showDateFormatDialog(context, ref, settings),
          ),
          _SettingsTile(
            icon: Icons.access_time_rounded,
            title: 'Time Format',
            subtitle: settings.timeFormat,
            onTap: () => _showTimeFormatDialog(context, ref, settings),
          ),
          _SettingsTile(
            icon: Icons.calendar_view_week_rounded,
            title: 'Start of Week',
            subtitle: settings.weekStartDay == 1 ? 'Monday' : 'Sunday',
            onTap: () {
              ref.read(settingsProvider.notifier).setWeekStartDay(
                    settings.weekStartDay == 1 ? 0 : 1,
                  );
            },
          ),

          // Security
          const _SectionHeader(title: 'Security'),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline_rounded),
            title: const Text('App Lock'),
            subtitle: const Text('Require PIN to open'),
            value: settings.pinEnabled,
            onChanged: (value) {
              if (value) {
                // Navigate to PIN setup
                context.push('${AppRoutes.pin}?setup=true');
              } else {
                ref.read(settingsProvider.notifier).setPinEnabled(false);
              }
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint_rounded),
            title: const Text('Biometric Lock'),
            subtitle: const Text('Use fingerprint or face'),
            value: settings.biometricEnabled,
            onChanged: settings.pinEnabled
                ? (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .setBiometricEnabled(value);
                  }
                : null,
          ),

          // Preferences
          const _SectionHeader(title: 'Preferences'),
          SwitchListTile(
            secondary: const Icon(Icons.attach_money_rounded),
            title: const Text('Show Cents'),
            subtitle: const Text('Display decimal places'),
            value: settings.showCents,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setShowCents(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration_rounded),
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibration on actions'),
            value: settings.hapticFeedback,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setHapticFeedback(value);
            },
          ),

          // Data
          const _SectionHeader(title: 'Data'),
          _SettingsTile(
            icon: Icons.backup_rounded,
            title: 'Backup & Restore',
            subtitle: 'Export or import your data',
            onTap: () => context.push(AppRoutes.backupRestore),
          ),
          _SettingsTile(
            icon: Icons.file_download_outlined,
            title: 'Export to CSV',
            subtitle: 'Export transactions as CSV',
            onTap: () => _exportCSV(context),
          ),

          // About
          const _SectionHeader(title: 'About'),
          const _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          _SettingsTile(
            icon: Icons.star_outline_rounded,
            title: 'Rate App',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.share_outlined,
            title: 'Share App',
            onTap: () {},
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeName(int themeModeIndex) {
    switch (themeModeIndex) {
      case 1:
        return 'Light';
      case 2:
        return 'Dark';
      default:
        return 'System default';
    }
  }

  void _showThemeDialog(
      BuildContext context, WidgetRef ref, SettingsModel settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme'),
        children: [
          RadioListTile<int>(
            title: const Text('System default'),
            value: 0,
            groupValue: settings.themeModeIndex,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setThemeMode(value!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<int>(
            title: const Text('Light'),
            value: 1,
            groupValue: settings.themeModeIndex,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setThemeMode(value!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<int>(
            title: const Text('Dark'),
            value: 2,
            groupValue: settings.themeModeIndex,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setThemeMode(value!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    final currencies = ['BDT', 'USD', 'EUR', 'GBP', 'INR', 'AED', 'SAR'];

    showDialog(
      context: context,
      builder: (context) {
        final settings = ref.read(settingsProvider);
        return SimpleDialog(
          title: const Text('Currency'),
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency),
              value: currency,
              groupValue: settings.defaultCurrency,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setDefaultCurrency(value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showDateFormatDialog(
      BuildContext context, WidgetRef ref, SettingsModel settings) {
    final formats = ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd'];

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Date Format'),
        children: formats.map((format) {
          return RadioListTile<String>(
            title: Text(format),
            value: format,
            groupValue: settings.dateFormat,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setDateFormat(value!);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showTimeFormatDialog(
      BuildContext context, WidgetRef ref, SettingsModel settings) {
    final formats = ['hh:mm a', 'HH:mm'];

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Time Format'),
        children: formats.map((format) {
          return RadioListTile<String>(
            title: Text(format == 'hh:mm a' ? '12-hour' : '24-hour'),
            value: format,
            groupValue: settings.timeFormat,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setTimeFormat(value!);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _exportCSV(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting to CSV...')),
    );
    // TODO: Implement CSV export
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
