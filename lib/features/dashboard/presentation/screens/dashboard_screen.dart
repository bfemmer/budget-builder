import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/presentation/viewmodels/category_viewmodel.dart';
import '../../../profile/presentation/viewmodels/profile_viewmodel.dart';
import '../../../transactions/presentation/viewmodels/transaction_viewmodel.dart';
import '../../../transactions/presentation/widgets/add_edit_transaction_modal.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/notification_sheet.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final catVm = Provider.of<CategoryViewModel>(context, listen: false);
    final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
    final txVm = Provider.of<TransactionViewModel>(context, listen: false);
    final dashVm = Provider.of<DashboardViewModel>(context, listen: false);

    await profileVm.loadProfile();
    await catVm.loadCategories();
    await txVm.loadTransactions(catVm);
    await dashVm.loadNotifications();
  }

  void _showNotificationsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileVm = Provider.of<ProfileViewModel>(context);
    final catVm = Provider.of<CategoryViewModel>(context);
    final txVm = Provider.of<TransactionViewModel>(context);
    final dashVm = Provider.of<DashboardViewModel>(context);

    final totalLimit = catVm.totalMonthlyLimit;
    final totalSpent = txVm.getTotalSpentCurrentMonth(catVm);
    final remaining = totalLimit - totalSpent;

    final double spendProgress = totalLimit > 0
        ? (totalSpent / totalLimit).clamp(0.0, 1.0)
        : 0.0;

    // Filter current month EXPENSE transactions only (excluding income)
    final currentMonthExpenseTx = txVm.transactions.where((t) {
      final d = DateTime.tryParse(t.date);
      final now = DateTime.now();
      if (d == null || d.month != now.month || d.year != now.year) return false;
      final cat = catVm.getCategoryById(t.categoryId);
      return cat == null || !cat.isIncome;
    }).toList();

    final needsSpent = currentMonthExpenseTx
        .where((t) => t.needOrWant == 'Need')
        .fold(0.0, (sum, t) => sum + t.amount);
    final wantsSpent = currentMonthExpenseTx
        .where((t) => t.needOrWant == 'Want')
        .fold(0.0, (sum, t) => sum + t.amount);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark
        ? AppColors.cardBorder
        : AppColors.lightCardBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = textPrimary.withValues(alpha: 0.65);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield, color: AppColors.usafGold, size: 24),
            const SizedBox(width: 8),
            Text(
              profileVm.profile?.lastName.isNotEmpty == true
                  ? 'Welcome, ${profileVm.profile!.firstName} ${profileVm.profile!.lastName}'
                  : 'Budget Builder',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: textPrimary),
                onPressed: _showNotificationsModal,
              ),
              if (dashVm.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.statusRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${dashVm.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Budget Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.airForceBlue, AppColors.navyCard]
                        : [AppColors.airForceBlue, const Color(0xFF0F2A4A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? AppColors.cardBorder
                        : AppColors.accentBlue.withValues(alpha: 0.3),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'MONTHLY OVERVIEW',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.usafGold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (remaining >= 0
                                        ? AppColors.statusGreen
                                        : AppColors.statusRed)
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            remaining >= 0 ? 'ON TRACK' : 'OVER BUDGET',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: remaining >= 0
                                  ? AppColors.statusGreen
                                  : AppColors.statusRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      CurrencyFormatter.format(totalSpent),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Total Spent of ${CurrencyFormatter.format(totalLimit)} Limit',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: spendProgress,
                        minHeight: 10,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          spendProgress >= 0.8
                              ? AppColors.statusRed
                              : (spendProgress >= 0.5
                                    ? AppColors.statusYellow
                                    : AppColors.statusGreen),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REMAINING BUDGET',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(remaining),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: remaining >= 0
                                    ? AppColors.statusGreen
                                    : AppColors.statusRed,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'SPEND PERCENTAGE',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(spendProgress * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.usafGold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Need vs Want Cards Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: AppColors.tagNeed,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'NEEDS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.tagNeed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(needsSpent),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalSpent > 0
                                ? '${((needsSpent / totalSpent) * 100).toStringAsFixed(0)}% of expenses'
                                : '0% of total',
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: AppColors.tagWant,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'WANTS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.tagWant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(wantsSpent),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalSpent > 0
                                ? '${((wantsSpent / totalSpent) * 100).toStringAsFixed(0)}% of expenses'
                                : '0% of total',
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentBlue,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                    icon: Icons.add_circle,
                    label: 'Add Expense',
                    color: AppColors.accentBlue,
                    textColor: textPrimary,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => AddEditTransactionModal(
                          onSave: (model) async {
                            await txVm.addTransaction(model, catVm);
                          },
                        ),
                      );
                    },
                  ),
                  _buildQuickActionButton(
                    icon: Icons.tune,
                    label: 'Set Limits',
                    color: AppColors.usafGold,
                    textColor: textPrimary,
                    onTap: () =>
                        widget.onNavigateTab(5), // Settings/Categories tab
                  ),
                  _buildQuickActionButton(
                    icon: Icons.volunteer_activism,
                    label: 'AFAS Relief',
                    color: AppColors.usafGold,
                    textColor: textPrimary,
                    onTap: () => widget.onNavigateTab(4), // AFAS Relief tab
                  ),
                  _buildQuickActionButton(
                    icon: Icons.bar_chart,
                    label: 'View Reports',
                    color: AppColors.statusGreen,
                    textColor: textPrimary,
                    onTap: () => widget.onNavigateTab(3), // Reports tab
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT TRANSACTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentBlue,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        widget.onNavigateTab(1), // Transactions tab
                    child: const Text(
                      'View All',
                      style: TextStyle(color: AppColors.accentBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              txVm.transactions.isEmpty
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
                          'No transactions yet. Tap "Add Transaction" to get started.',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: txVm.transactions.take(5).length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final t = txVm.transactions[index];
                        final cat = catVm.getCategoryById(t.categoryId);

                        return Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    (cat != null
                                            ? Color(cat.colorValue)
                                            : AppColors.accentBlue)
                                        .withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cat?.isIncome == true
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: cat?.isIncome == true
                                    ? AppColors.statusGreen
                                    : AppColors.accentBlue,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              t.description,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              cat?.name ?? 'Category',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                            trailing: Text(
                              CurrencyFormatter.format(t.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
