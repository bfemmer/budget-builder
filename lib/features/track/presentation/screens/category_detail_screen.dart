import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../transactions/presentation/viewmodels/transaction_viewmodel.dart';

class CategoryDetailScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final txVm = Provider.of<TransactionViewModel>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? AppColors.cardBorder : AppColors.lightCardBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = textPrimary.withValues(alpha: 0.65);
    final textMuted = textPrimary.withValues(alpha: 0.45);

    // Filter transactions for this category in the current month
    final now = DateTime.now();
    final categoryTx = txVm.transactions.where((t) {
      if (t.categoryId != category.id) return false;
      final d = DateTime.tryParse(t.date);
      return d != null && d.month == now.month && d.year == now.year;
    }).toList();

    final double spent = categoryTx.fold(0.0, (sum, t) => sum + t.amount);
    final double remaining = category.monthlyLimit - spent;
    final double ratio = category.monthlyLimit > 0 ? spent / category.monthlyLimit : 0.0;

    Color statusColor = AppColors.statusGreen;
    if (ratio >= 0.8) {
      statusColor = AppColors.statusRed;
    } else if (ratio >= 0.5) {
      statusColor = AppColors.statusYellow;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ratio >= 1.0
                                ? 'EXCEEDED LIMIT'
                                : (ratio >= 0.8
                                    ? 'NEAR LIMIT (80%+)'
                                    : (ratio >= 0.5 ? 'MODERATE (50%+)' : 'NORMAL (<50%)')),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(ratio * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('BUDGET LIMIT', style: TextStyle(fontSize: 11, color: textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(category.monthlyLimit),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: borderColor),
                      Column(
                        children: [
                          Text('SPENT', style: TextStyle(fontSize: 11, color: textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(spent),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: borderColor),
                      Column(
                        children: [
                          Text('REMAINING', style: TextStyle(fontSize: 11, color: textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(remaining),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: remaining >= 0 ? AppColors.statusGreen : AppColors.statusRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'MONTHLY TRANSACTIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.accentBlue,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            categoryTx.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Text(
                        'No transactions recorded for this category this month.',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryTx.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final t = categoryTx[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            title: Text(t.description, style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
                            subtitle: Text(
                              '${t.vendor.isNotEmpty ? "${t.vendor} • " : ""}${t.paymentType} • ${t.needOrWant}',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(t.amount),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary),
                                ),
                                Text(
                                  DateFormatter.formatShort(DateFormatter.parseIso(t.date)),
                                  style: TextStyle(fontSize: 11, color: textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
