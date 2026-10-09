import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../categories/presentation/viewmodels/category_viewmodel.dart';
import '../../data/models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../widgets/add_edit_transaction_modal.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _filterCategoryId;
  String? _filterNeedWant;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddModal([TransactionModel? t]) {
    final catVm = Provider.of<CategoryViewModel>(context, listen: false);
    final txVm = Provider.of<TransactionViewModel>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditTransactionModal(
        transaction: t,
        onSave: (model) async {
          if (t == null) {
            await txVm.addTransaction(model, catVm);
          } else {
            await txVm.updateTransaction(model, catVm);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txVm = Provider.of<TransactionViewModel>(context);
    final catVm = Provider.of<CategoryViewModel>(context);

    // Apply search and category filter
    final query = _searchController.text.toLowerCase().trim();
    List<TransactionModel> filtered = txVm.transactions.where((t) {
      if (_filterCategoryId != null && t.categoryId != _filterCategoryId) {
        return false;
      }
      if (_filterNeedWant != null && t.needOrWant != _filterNeedWant) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchesDesc = t.description.toLowerCase().contains(query);
        final matchesVendor = t.vendor.toLowerCase().contains(query);
        return matchesDesc || matchesVendor;
      }
      return true;
    }).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final modalColor =
        theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;
    final borderColor = isDark
        ? AppColors.cardBorder
        : AppColors.lightCardBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = textPrimary.withValues(alpha: 0.65);
    final textMuted = textPrimary.withValues(alpha: 0.45);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: textSecondary),
            tooltip: 'Filter Options',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                backgroundColor: modalColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int?>(
                            initialValue: _filterCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Filter by Category',
                            ),
                            dropdownColor: cardColor,
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...catVm.categories.map((c) {
                                return DropdownMenuItem<int?>(
                                  value: c.id,
                                  child: Text(c.name),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() => _filterCategoryId = val);
                              Navigator.pop(ctx);
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _filterCategoryId = null;
                                      _filterNeedWant = null;
                                      _searchController.clear();
                                    });
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Reset Filters'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Need/Want Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search vendor or description...',
                    prefixIcon: Icon(Icons.search, color: textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _searchController.clear()),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterNeedWant == null,
                        selectedColor: AppColors.accentBlue.withValues(
                          alpha: 0.3,
                        ),
                        onSelected: (_) =>
                            setState(() => _filterNeedWant = null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Needs Only'),
                        selected: _filterNeedWant == 'Need',
                        selectedColor: AppColors.tagNeed.withValues(alpha: 0.3),
                        onSelected: (_) =>
                            setState(() => _filterNeedWant = 'Need'),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Wants Only'),
                        selected: _filterNeedWant == 'Want',
                        selectedColor: AppColors.tagWant.withValues(alpha: 0.3),
                        onSelected: (_) =>
                            setState(() => _filterNeedWant = 'Want'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: txVm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions recorded yet',
                          style: TextStyle(fontSize: 16, color: textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Record First Transaction'),
                          onPressed: () => _openAddModal(),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      final cat = catVm.getCategoryById(t.categoryId);
                      final catColor = cat != null
                          ? Color(cat.colorValue)
                          : AppColors.accentBlue;

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
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat?.isIncome == true
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: cat?.isIncome == true
                                  ? AppColors.statusGreen
                                  : catColor,
                            ),
                          ),
                          title: Text(
                            t.description,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: cat?.name ?? 'Category'),
                                    if (t.vendor.isNotEmpty) ...[
                                      TextSpan(
                                        text: ' • ',
                                        style: TextStyle(color: textMuted),
                                      ),
                                      TextSpan(text: t.vendor),
                                    ],
                                  ],
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  // Need/Want Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (t.needOrWant == 'Need'
                                                  ? AppColors.tagNeed
                                                  : AppColors.tagWant)
                                              .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      t.needOrWant.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: t.needOrWant == 'Need'
                                            ? AppColors.tagNeed
                                            : AppColors.tagWant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Payment Type Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (t.paymentType == 'Credit'
                                                  ? AppColors.tagCredit
                                                  : AppColors.tagCash)
                                              .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      t.paymentType.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: t.paymentType == 'Credit'
                                            ? AppColors.tagCredit
                                            : AppColors.tagCash,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.format(t.amount),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: cat?.isIncome == true
                                      ? AppColors.statusGreen
                                      : textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormatter.formatShort(
                                  DateFormatter.parseIso(t.date),
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              useSafeArea: true,
                              backgroundColor: modalColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (ctx) => SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.edit,
                                        color: AppColors.accentBlue,
                                      ),
                                      title: Text(
                                        'Edit Transaction',
                                        style: TextStyle(color: textPrimary),
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _openAddModal(t);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.delete,
                                        color: AppColors.statusRed,
                                      ),
                                      title: const Text(
                                        'Delete Transaction',
                                        style: TextStyle(
                                          color: AppColors.statusRed,
                                        ),
                                      ),
                                      onTap: () async {
                                        Navigator.pop(ctx);
                                        if (t.id != null) {
                                          await txVm.deleteTransaction(
                                            t.id!,
                                            catVm,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
        onPressed: () => _openAddModal(),
      ),
    );
  }
}
