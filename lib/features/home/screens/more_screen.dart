import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

/// More Screen - Additional features and settings
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Actions Section
          _buildSection(
            context,
            title: 'Quick Actions',
            children: [
              _buildMenuItem(
                context,
                icon: Icons.category_outlined,
                title: 'Categories',
                subtitle: 'Manage expense & income categories',
                onTap: () => context.push(AppRoutes.categories),
              ),
              _buildMenuItem(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Accounts',
                subtitle: 'Manage your accounts',
                onTap: () => context.push(AppRoutes.accounts),
              ),
              _buildMenuItem(
                context,
                icon: Icons.calendar_today_outlined,
                title: 'Calendar View',
                subtitle: 'View expenses on calendar',
                onTap: () => context.push(AppRoutes.calendar),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Financial Tools Section
          _buildSection(
            context,
            title: 'Financial Tools',
            children: [
              _buildMenuItem(
                context,
                icon: Icons.savings_outlined,
                title: 'Savings Goals',
                subtitle: 'Track your savings targets',
                onTap: () => context.push(AppRoutes.goals),
                badge: 'NEW',
              ),
              _buildMenuItem(
                context,
                icon: Icons.swap_horiz_rounded,
                title: 'Debts & Loans',
                subtitle: 'Track borrowed and lent money',
                onTap: () => context.push(AppRoutes.debts),
              ),
              _buildMenuItem(
                context,
                icon: Icons.analytics_outlined,
                title: 'Reports',
                subtitle: 'Detailed financial analytics',
                onTap: () {
                  // Navigate to reports tab
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Data Section
          _buildSection(
            context,
            title: 'Data',
            children: [
              _buildMenuItem(
                context,
                icon: Icons.backup_outlined,
                title: 'Backup & Restore',
                subtitle: 'Export and import your data',
                onTap: () => context.push(AppRoutes.backupRestore),
              ),
              _buildMenuItem(
                context,
                icon: Icons.file_download_outlined,
                title: 'Export to CSV',
                subtitle: 'Export transactions as spreadsheet',
                onTap: () => _exportToCSV(context, ref),
              ),
              _buildMenuItem(
                context,
                icon: Icons.picture_as_pdf_outlined,
                title: 'Generate PDF Report',
                subtitle: 'Create printable report',
                onTap: () => _generatePDF(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Settings Section
          _buildSection(
            context,
            title: 'Settings',
            children: [
              _buildMenuItem(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'App preferences and customization',
                onTap: () => context.push(AppRoutes.settings),
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: context.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _exportToCSV(BuildContext context, WidgetRef ref) {
    // TODO: Implement CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV export coming soon!')),
    );
  }

  void _generatePDF(BuildContext context, WidgetRef ref) {
    // TODO: Implement PDF generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF generation coming soon!')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded,
                color: Color(0xFF6C63FF)),
            SizedBox(width: 12),
            Text('Spendora'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A beautiful, fully offline expense tracker app to help you manage your finances.',
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 Spendora',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
