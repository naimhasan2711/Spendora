import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

/// Backup & Restore Screen
class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Card(
            color: context.colorScheme.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your data is stored locally on this device. Create backups regularly to prevent data loss.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Backup Section
          Text(
            'BACKUP',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.backup_rounded,
                        color: AppTheme.success),
                  ),
                  title: const Text('Create Backup'),
                  subtitle: const Text('Export all data to a file'),
                  trailing: _isBackingUp
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isBackingUp ? null : _createBackup,
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          context.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.schedule_rounded,
                        color: context.colorScheme.primary),
                  ),
                  title: const Text('Auto Backup'),
                  subtitle: const Text('Daily automatic backups'),
                  trailing: Switch(
                    value: false, // TODO: Get from settings
                    onChanged: (value) {
                      // TODO: Toggle auto backup
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Restore Section
          Text(
            'RESTORE',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.restore_rounded, color: AppTheme.warning),
              ),
              title: const Text('Restore from Backup'),
              subtitle: const Text('Import data from a backup file'),
              trailing: _isRestoring
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isRestoring ? null : _restoreBackup,
            ),
          ),
          const SizedBox(height: 24),

          // Danger Zone
          Text(
            'DANGER ZONE',
            style: context.textTheme.labelSmall?.copyWith(
              color: AppTheme.error,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_forever_rounded,
                    color: AppTheme.error),
              ),
              title: const Text('Reset All Data'),
              subtitle:
                  const Text('Delete all transactions, budgets, and settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _confirmReset,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);

    try {
      // TODO: Implement backup
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup created successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _restoreBackup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace all current data with the backup data. This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRestoring = true);

    try {
      // TODO: Implement restore
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data restored successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  Future<void> _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will permanently delete ALL your data including transactions, budgets, goals, and settings. This action CANNOT be undone.\n\nAre you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: Reset all data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been reset'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }
}
