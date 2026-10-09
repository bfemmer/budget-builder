import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/presentation/viewmodels/category_viewmodel.dart';
import '../../../transactions/presentation/viewmodels/transaction_viewmodel.dart';
import 'category_detail_screen.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catVm = Provider.of<CategoryViewModel>(context, listen: false);
      Provider.of<TransactionViewModel>(
        context,
        listen: false,
      ).loadTransactions(catVm);
    });
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'fastfood':
        return Icons.fastfood;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'school':
        return Icons.school;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'spa':
        return Icons.spa;
      case 'flight':
        return Icons.flight;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catVm = Provider.of<CategoryViewModel>(context);
    final txVm = Provider.of<TransactionViewModel>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? AppColors.cardBorder : AppColors.lightCardBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = textPrimary.withValues(alpha: 0.65);
    final textMuted = textPrimary.withValues(alpha: 0.45);

    return Scaffold(
      appBar: AppBar(title: const Text('My Spending Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color Legend Card (Directly matching Page 5 of AFAS User Guide!)
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
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATUS LEGEND (CALCULATIONS RESET MONTHLY)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.usafGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem(
                    color: AppColors.statusGreen,
                    label: 'GREEN – Spending is less than 50% of limit',
                    textColor: textSecondary,
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    color: AppColors.statusYellow,
                    label: 'YELLOW – Spending reached 50% - 79% of limit',
                    textColor: textSecondary,
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    color: AppColors.statusRed,
                    label: 'RED – Spending reached at least 80% of limit',
                    textColor: textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'CATEGORY SPENDING STATUS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.accentBlue,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            catVm.expenseCategories.isEmpty
                ? Center(child: Text('No categories defined', style: TextStyle(color: textSecondary)))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: catVm.expenseCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cat = catVm.expenseCategories[index];
                      final double spent = cat.id != null
                          ? txVm.getSpentForCategory(cat.id!)
                          : 0.0;
                      final double limit = cat.monthlyLimit;
                      final double ratio = limit > 0 ? spent / limit : 0.0;

                      Color indicatorColor = AppColors.statusGreen;
                      if (ratio >= 0.8) {
                        indicatorColor = AppColors.statusRed;
                      } else if (ratio >= 0.5) {
                        indicatorColor = AppColors.statusYellow;
                      }

                      return Container(
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
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(cat.colorValue)
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconData(cat.iconName),
                              color: Color(cat.colorValue),
                            ),
                          ),
                          title: Text(
                            cat.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Spent: ${CurrencyFormatter.format(spent)} / Limit: ${CurrencyFormatter.format(limit)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: indicatorColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: indicatorColor.withValues(
                                        alpha: 0.6,
                                      ),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: textMuted,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CategoryDetailScreen(category: cat),
                              ),
                            );
                          },
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

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required Color textColor,
  }) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
