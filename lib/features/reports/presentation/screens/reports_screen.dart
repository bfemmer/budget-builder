import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/presentation/viewmodels/category_viewmodel.dart';
import '../viewmodels/reports_viewmodel.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsViewModel>(context, listen: false).loadReportData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsVm = Provider.of<ReportsViewModel>(context);
    final catVm = Provider.of<CategoryViewModel>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? AppColors.cardBorder : AppColors.lightCardBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = textPrimary.withValues(alpha: 0.65);

    final totalExpenses = reportsVm.getTotalExpenses(catVm);
    final totalIncome = reportsVm.getTotalIncome(catVm);
    final netCashFlow = reportsVm.getNetCashFlow(catVm);

    final expenseMap = reportsVm.getExpenseCategoryMap(catVm);
    final incomeMap = reportsVm.getIncomeCategoryMap(catVm);

    final needsSpent = reportsVm.getNeedsExpenses(catVm);
    final wantsSpent = reportsVm.getWantsExpenses(catVm);

    final expenseCount = reportsVm.getExpenseTransactions(catVm).length;
    final incomeCount = reportsVm.getIncomeTransactions(catVm).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial & Spending Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeframe Segmented Control
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  _buildSegmentButton(
                    label: '7 Days',
                    isSelected: reportsVm.selectedTimeframe == ReportTimeframe.last7Days,
                    onTap: () => reportsVm.setTimeframe(ReportTimeframe.last7Days),
                    textColor: textSecondary,
                  ),
                  _buildSegmentButton(
                    label: 'Last Month',
                    isSelected: reportsVm.selectedTimeframe == ReportTimeframe.lastMonth,
                    onTap: () => reportsVm.setTimeframe(ReportTimeframe.lastMonth),
                    textColor: textSecondary,
                  ),
                  _buildSegmentButton(
                    label: 'Year-to-Date',
                    isSelected: reportsVm.selectedTimeframe == ReportTimeframe.yearToDate,
                    onTap: () => reportsVm.setTimeframe(ReportTimeframe.yearToDate),
                    textColor: textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Income vs Expense Cash Flow Comparison Card (Hero Card)
            Container(
              width: double.infinity,
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
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CASH FLOW SUMMARY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.usafGold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (netCashFlow >= 0 ? AppColors.statusGreen : AppColors.statusRed)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          netCashFlow >= 0 ? 'NET SURPLUS' : 'NET DEFICIT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: netCashFlow >= 0 ? AppColors.statusGreen : AppColors.statusRed,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Income & Expense Metrics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.arrow_downward, color: AppColors.statusGreen, size: 16),
                              SizedBox(width: 4),
                              Text('TOTAL INCOME', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(totalIncome),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.statusGreen),
                          ),
                        ],
                      ),
                      Container(height: 36, width: 1, color: Colors.white24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.arrow_upward, color: AppColors.statusRed, size: 16),
                              SizedBox(width: 4),
                              Text('TOTAL EXPENSES', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(totalExpenses),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),

                  // Net Cash Flow Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net Cash Flow (Income - Expenses):',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      Text(
                        '${netCashFlow >= 0 ? '+' : ''}${CurrencyFormatter.format(netCashFlow)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: netCashFlow >= 0 ? AppColors.statusGreen : AppColors.statusRed,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    '$expenseCount Expenses • $incomeCount Income Records',
                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Need vs Want Analysis Card (Expenses Only)
            const Text(
              'AFAS FINANCIAL AWARENESS (NEED VS WANT EXPENSES)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.accentBlue,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

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
                      _buildNeedWantMetric('NEEDS (Essential)', needsSpent, totalExpenses, AppColors.tagNeed, textPrimary, textSecondary),
                      _buildNeedWantMetric('WANTS (Discretionary)', wantsSpent, totalExpenses, AppColors.tagWant, textPrimary, textSecondary),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stacked Need vs Want Bar
                  if (totalExpenses > 0)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 14,
                        child: Row(
                          children: [
                            Expanded(
                              flex: (needsSpent * 100).toInt(),
                              child: Container(color: AppColors.tagNeed),
                            ),
                            Expanded(
                              flex: (wantsSpent * 100).toInt(),
                              child: Container(color: AppColors.tagWant),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Spending by Category List (Expenses Only)
            const Text(
              'SPENDING BY CATEGORY (EXPENSES ONLY)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.accentBlue,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            expenseMap.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Text(
                        'No expense transactions for selected timeframe.',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenseMap.keys.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final categoryId = expenseMap.keys.elementAt(index);
                      final spent = expenseMap[categoryId] ?? 0.0;
                      final cat = catVm.getCategoryById(categoryId);
                      final percent = totalExpenses > 0 ? (spent / totalExpenses) * 100 : 0.0;
                      final color = cat != null ? Color(cat.colorValue) : AppColors.accentBlue;

                      return Container(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat?.name ?? 'Category',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
                                    ),
                                  ],
                                ),
                                Text(
                                  CurrencyFormatter.format(spent),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: totalExpenses > 0 ? spent / totalExpenses : 0.0,
                                      minHeight: 8,
                                      backgroundColor: isDark ? AppColors.inputBackground : AppColors.lightInputBackground,
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${percent.toStringAsFixed(1)}%',
                                  style: TextStyle(fontSize: 12, color: textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

            // Income Sources Section (if income exists)
            if (incomeMap.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'INCOME SOURCES IN TIMEFRAME',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.statusGreen,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: incomeMap.keys.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final categoryId = incomeMap.keys.elementAt(index);
                  final amount = incomeMap[categoryId] ?? 0.0;
                  final cat = catVm.getCategoryById(categoryId);

                  return Container(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.statusGreen.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.statusGreen,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              cat?.name ?? 'Income',
                              style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.statusGreen,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeedWantMetric(
    String label,
    double amount,
    double total,
    Color color,
    Color textPrimary,
    Color textSecondary,
  ) {
    final pct = total > 0 ? (amount / total) * 100 : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
        ),
        Text('${pct.toStringAsFixed(1)}% of total expenses', style: TextStyle(fontSize: 11, color: textSecondary)),
      ],
    );
  }
}
