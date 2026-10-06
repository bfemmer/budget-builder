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

    final totalSpent = reportsVm.totalSpentInTimeframe;
    final categoryMap = reportsVm.categorySpendingMap;
    final needsSpent = reportsVm.totalNeedsInTimeframe;
    final wantsSpent = reportsVm.totalWantsInTimeframe;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Reports'),
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
                color: AppColors.navyCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _buildSegmentButton(
                    label: '7 Days',
                    isSelected: reportsVm.selectedTimeframe == ReportTimeframe.last7Days,
                    onTap: () => reportsVm.setTimeframe(ReportTimeframe.last7Days),
                  ),
                  _buildSegmentButton(
                    label: 'Last Month',
                    isSelected: reportsVm.selectedTimeframe == ReportTimeframe.lastMonth,
                    onTap: () => reportsVm.setTimeframe(ReportTimeframe.lastMonth),
                  ),
                  _buildSegmentButton(
                    label: 'Year-to-Date',
                    isSelected: reportsVm.selectedTimeframe == ReportTimeframe.yearToDate,
                    onTap: () => reportsVm.setTimeframe(ReportTimeframe.yearToDate),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Summary Total Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.airForceBlue, AppColors.navyCard],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL EXPENDITURE IN TIMEFRAME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.usafGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(totalSpent),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reportsVm.filteredTransactions.length} Transactions Recorded',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Need vs Want Analysis Card
            const Text(
              'AFAS FINANCIAL AWARENESS (NEED VS WANT)',
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
                color: AppColors.navyCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNeedWantMetric('NEEDS (Essential)', needsSpent, totalSpent, AppColors.tagNeed),
                      _buildNeedWantMetric('WANTS (Discretionary)', wantsSpent, totalSpent, AppColors.tagWant),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stacked Need vs Want Bar
                  if (totalSpent > 0)
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

            // Category Breakdown Chart / List
            const Text(
              'SPENDING BY CATEGORY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.accentBlue,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            categoryMap.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.navyCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Center(
                      child: Text(
                        'No expenditure data for selected timeframe.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryMap.keys.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final categoryId = categoryMap.keys.elementAt(index);
                      final spent = categoryMap[categoryId] ?? 0.0;
                      final cat = catVm.getCategoryById(categoryId);
                      final percent = totalSpent > 0 ? (spent / totalSpent) * 100 : 0.0;
                      final color = cat != null ? Color(cat.colorValue) : AppColors.accentBlue;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.navyCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
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
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  CurrencyFormatter.format(spent),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                                      value: totalSpent > 0 ? spent / totalSpent : 0.0,
                                      minHeight: 8,
                                      backgroundColor: AppColors.inputBackground,
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${percent.toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
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
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeedWantMetric(String label, double amount, double total, Color color) {
    final pct = total > 0 ? (amount / total) * 100 : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(amount),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text('${pct.toStringAsFixed(1)}% of total', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
