import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/settings_model.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../providers/settings_provider.dart';

/// Settings Screen - Streamlined version
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const ProfileAvatar(radius: 16),
            const SizedBox(width: 12),
            Text(
              'Settings',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D4A3E),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Security Section - App Lock only (removed Biometric)
          AnimatedFadeSlide(
            delay: const Duration(milliseconds: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Security'),
                _SettingsCard(
                  children: [
                    _SettingsToggleTile(
                      icon: Icons.lock_outline_rounded,
                      iconColor: context.colorScheme.primary,
                      title: 'App Lock',
                      subtitle: 'Require PIN to open app',
                      value: settings.pinEnabled,
                      onChanged: (value) {
                        if (value) {
                          context.push('${AppRoutes.pin}?setup=true');
                        } else {
                          ref
                              .read(settingsProvider.notifier)
                              .setPinEnabled(false);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Preferences Section - Currency and Theme (removed Language)
          AnimatedFadeSlide(
            delay: const Duration(milliseconds: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Preferences'),
                _SettingsCard(
                  children: [
                    _SettingsDropdownTile(
                      icon: Icons.attach_money_rounded,
                      iconColor: AppTheme.income,
                      title: 'Default Currency',
                      value:
                          '${settings.defaultCurrency} (${_getCurrencySymbol(settings.defaultCurrency)})',
                      onTap: () => _showCurrencyDialog(context, ref),
                    ),
                    _SettingsDropdownTile(
                      icon: Icons.dark_mode_rounded,
                      iconColor: isDark ? Colors.amber : Colors.blueGrey,
                      title: 'Theme',
                      value: _getThemeName(settings.themeModeIndex),
                      onTap: () => _showThemeDialog(context, ref, settings),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Data Management Section
          AnimatedFadeSlide(
            delay: const Duration(milliseconds: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Data Management'),
                _SettingsCard(
                  children: [
                    _SettingsActionTile(
                      icon: Icons.download_rounded,
                      iconColor: context.colorScheme.primary,
                      title: 'Export Data',
                      subtitle: 'Download PDF/CSV history',
                      onTap: () => _showExportOptions(context),
                    ),
                    _SettingsActionTile(
                      icon: Icons.sync_rounded,
                      iconColor: AppTheme.info,
                      title: 'Backup & Restore',
                      subtitle: settings.lastBackupDate != null
                          ? 'Last synced: ${_formatDate(settings.lastBackupDate!)}'
                          : 'Last synced: Never',
                      onTap: () => context.push(AppRoutes.backupRestore),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Support & About Section
          AnimatedFadeSlide(
            delay: const Duration(milliseconds: 250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Support & About'),
                _SettingsCard(
                  children: [
                    _SettingsActionTile(
                      icon: Icons.star_outline_rounded,
                      iconColor: Colors.amber,
                      title: 'Rate Spendora',
                      showExternalIcon: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Thank you for your support!')),
                        );
                      },
                    ),
                    _SettingsActionTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: AppTheme.info,
                      title: 'Help Center',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Help Center coming soon!')),
                        );
                      },
                    ),
                    _SettingsActionTile(
                      icon: Icons.description_outlined,
                      iconColor:
                          context.colorScheme.onSurface.withValues(alpha: 0.6),
                      title: 'Terms of Service',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Terms of Service coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Version Info
          AnimatedFadeSlide(
            delay: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Spendora Version 1.0.0 (Build 1)',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'BDT':
        return '৳';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'AED':
        return 'د.إ';
      case 'SAR':
        return '﷼';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      default:
        return code;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Export Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppTheme.error),
              ),
              title: const Text('Download PDF'),
              subtitle: const Text('Detailed Visual Report'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                _generatePDFReport(context);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.table_chart_rounded,
                    color: AppTheme.success),
              ),
              title: const Text('Download CSV'),
              subtitle: const Text('Raw Data for Excel'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                _exportCSV(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getThemeName(int themeModeIndex) {
    switch (themeModeIndex) {
      case 1:
        return 'Light Mode';
      case 2:
        return 'Dark Mode';
      default:
        return 'System';
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
    final currencies = [
      ('BDT', '৳', 'Bangladeshi Taka'),
      ('USD', '\$', 'US Dollar'),
      ('EUR', '€', 'Euro'),
      ('GBP', '£', 'British Pound'),
      ('INR', '₹', 'Indian Rupee'),
      ('AED', 'د.إ', 'UAE Dirham'),
      ('SAR', '﷼', 'Saudi Riyal'),
      ('JPY', '¥', 'Japanese Yen'),
      ('CNY', '¥', 'Chinese Yuan'),
      ('CAD', 'C\$', 'Canadian Dollar'),
      ('AUD', 'A\$', 'Australian Dollar'),
    ];

    showDialog(
      context: context,
      builder: (context) {
        final settings = ref.read(settingsProvider);
        return SimpleDialog(
          title: const Text('Default Currency'),
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text('${currency.$1} (${currency.$2})'),
              subtitle: Text(currency.$3),
              value: currency.$1,
              groupValue: settings.defaultCurrency,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setDefaultCurrency(value!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Currency changed to ${currency.$3}'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _exportCSV(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await ExportService.instance.shareCSV();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'CSV exported successfully!'
                  : 'Failed to export CSV. Please try again.',
            ),
            backgroundColor: success ? AppTheme.success : AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _generatePDFReport(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await ExportService.instance.sharePDFReport();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'PDF report generated successfully!'
                  : 'Failed to generate PDF report.',
            ),
            backgroundColor: success ? AppTheme.success : AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }
}

// ============================================================================
// Helper Widgets
// ============================================================================

/// Section Header Widget
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
          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Settings Card Container
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A3A34),
                  const Color(0xFF0D524A),
                  const Color(0xFF0A3D36)
                ]
              : [
                  const Color(0xFF0D6B5E),
                  const Color(0xFF14A085),
                  const Color(0xFF0D6B5E)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6B5E).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 72,
                color: Colors.white.withValues(alpha: 0.2),
              ),
          ],
        ],
      ),
    );
  }
}

/// Settings Toggle Tile (with Switch)
class _SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }
}

/// Settings Dropdown Tile (with dropdown value)
class _SettingsDropdownTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SettingsDropdownTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// Settings Action Tile (with chevron)
class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool showExternalIcon;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.showExternalIcon = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)))
          : null,
      trailing: Icon(
        showExternalIcon ? Icons.open_in_new_rounded : Icons.chevron_right,
        color: Colors.white.withValues(alpha: 0.7),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
