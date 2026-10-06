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
                color: AppColors.navyCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
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
                          const Text('BUDGET LIMIT', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(category.monthlyLimit),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: AppColors.cardBorder),
                      Column(
                        children: [
                          const Text('SPENT', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(spent),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: AppColors.cardBorder),
                      Column(
                        children: [
                          const Text('REMAINING', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
                      color: AppColors.navyCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Center(
                      child: Text(
                        'No transactions recorded for this category this month.',
                        style: TextStyle(color: AppColors.textSecondary),
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
                          color: AppColors.navyCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: ListTile(
                          title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${t.vendor.isNotEmpty ? "${t.vendor} • " : ""}${t.paymentType} • ${t.needOrWant}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.format(t.amount),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                DateFormatter.formatShort(DateFormatter.parseIso(t.date)),
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
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
