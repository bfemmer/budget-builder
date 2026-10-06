import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryViewModel>(context, listen: false).loadCategories();
    });
  }

  void _showAddEditCategoryModal([CategoryModel? category]) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final limitController = TextEditingController(
      text: category != null ? category.monthlyLimit.toStringAsFixed(2) : '',
    );
    bool isIncome = category?.isIncome ?? false;
    int selectedColor = category?.colorValue ?? 0xFF0066FF;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navySurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Spending Limit' : 'Add Category',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'e.g. Dining Out, Groceries',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: limitController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Limit (\$)',
                      hintText: '0.00',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Income Category'),
                    subtitle: const Text(
                      'Check if this represents an income source',
                    ),
                    value: isIncome,
                    activeThumbColor: AppColors.statusGreen,
                    onChanged: (val) {
                      setModalState(() => isIncome = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final limit =
                            double.tryParse(limitController.text.trim()) ?? 0.0;
                        if (name.isEmpty) return;

                        final vm = Provider.of<CategoryViewModel>(
                          context,
                          listen: false,
                        );
                        if (isEditing) {
                          await vm.updateCategory(
                            category.copyWith(
                              name: name,
                              monthlyLimit: limit,
                              isIncome: isIncome,
                              colorValue: selectedColor,
                            ),
                          );
                        } else {
                          await vm.addCategory(
                            CategoryModel(
                              name: name,
                              monthlyLimit: limit,
                              isIncome: isIncome,
                              colorValue: selectedColor,
                              iconName: isIncome
                                  ? 'account_balance_wallet'
                                  : 'shopping_bag',
                            ),
                          );
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      child: Text(
                        isEditing ? 'UPDATE LIMIT' : 'CREATE CATEGORY',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    final vm = Provider.of<CategoryViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Limits'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.accentBlue,
              size: 28,
            ),
            onPressed: () => _showAddEditCategoryModal(),
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Budget Header
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
                          'TOTAL MONTHLY SPENDING LIMIT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.usafGold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.format(vm.totalMonthlyLimit),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vm.expenseCategories.length} Spending Categories Configured',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'EXPENSE CATEGORIES & LIMITS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentBlue,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.expenseCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cat = vm.expenseCategories[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.navyCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Monthly Limit: ${CurrencyFormatter.format(cat.monthlyLimit)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: AppColors.accentBlue,
                                  size: 20,
                                ),
                                onPressed: () => _showAddEditCategoryModal(cat),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.statusRed,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Category?'),
                                      content: Text(
                                        'Are you sure you want to delete ${cat.name}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppColors.statusRed,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && cat.id != null) {
                                    await vm.deleteCategory(cat.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  if (vm.incomeCategories.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'INCOME SOURCES',
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
                      itemCount: vm.incomeCategories.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cat = vm.incomeCategories[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.navyCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.statusGreen.withValues(
                                  alpha: 0.2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.statusGreen,
                              ),
                            ),
                            title: Text(
                              cat.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: const Text(
                              'Income Category',
                              style: TextStyle(color: AppColors.statusGreen),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.accentBlue,
                                size: 20,
                              ),
                              onPressed: () => _showAddEditCategoryModal(cat),
                            ),
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
}
