import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../categories/presentation/viewmodels/category_viewmodel.dart';
import '../../../profile/presentation/viewmodels/profile_viewmodel.dart';
import '../../../transactions/presentation/viewmodels/transaction_viewmodel.dart';
import '../viewmodels/backup_viewmodel.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final TextEditingController _importController = TextEditingController();
  String? _exportedJson;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  void _refreshAllViewModels() async {
    final catVm = Provider.of<CategoryViewModel>(context, listen: false);
    final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
    final txVm = Provider.of<TransactionViewModel>(context, listen: false);

    await profileVm.loadProfile();
    await catVm.loadCategories();
    await txVm.loadTransactions(catVm);
  }

  @override
  Widget build(BuildContext context) {
    final backupVm = Provider.of<BackupViewModel>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? AppColors.cardBorder : AppColors.lightCardBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = textPrimary.withValues(alpha: 0.65);
    final inputBg = isDark ? AppColors.inputBackground : AppColors.lightInputBackground;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Data Transfer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.airForceBlue, AppColors.navyCard]
                      : [AppColors.airForceBlue, const Color(0xFF0F2A4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.cardBorder : AppColors.accentBlue.withValues(alpha: 0.3),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.sd_storage, size: 36, color: AppColors.usafGold),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOCAL DATA EXPORT & IMPORT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.usafGold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Export your budget data to local JSON or restore previously backed-up files without any cloud dependence.',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Export Section
            const Text(
              'EXPORT DATA (JSON)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.accentBlue,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate full backup JSON containing your profile, custom spending categories, and recorded transactions.',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('GENERATE BACKUP JSON'),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final json = await backupVm.exportToJson();
                        if (!mounted) return;
                        if (json != null) {
                          setState(() => _exportedJson = json);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Backup file created in App Documents folder!'),
                              backgroundColor: AppColors.statusGreen,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  if (_exportedJson != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exported Content Preview:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy JSON'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _exportedJson!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('JSON copied to clipboard!')),
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      height: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _exportedJson!,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Import Section
            const Text(
              'IMPORT DATA (RESTORE)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.accentBlue,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paste exported JSON backup code below to restore your budget data into the local database.',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _importController,
                    maxLines: 5,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Paste backup JSON string here...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('RESTORE FROM JSON'),
                      onPressed: () async {
                        final text = _importController.text.trim();
                        if (text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please paste JSON data first')),
                          );
                          return;
                        }
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await backupVm.importFromJson(text);
                        if (!mounted) return;
                        if (success) {
                          _refreshAllViewModels();
                          _importController.clear();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Database restored successfully!'),
                              backgroundColor: AppColors.statusGreen,
                            ),
                          );
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Failed to restore database. Check JSON syntax.'),
                              backgroundColor: AppColors.statusRed,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
