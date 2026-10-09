import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../categories/presentation/viewmodels/category_viewmodel.dart';
import '../../data/models/transaction_model.dart';

class AddEditTransactionModal extends StatefulWidget {
  final TransactionModel? transaction;
  final Function(TransactionModel) onSave;

  const AddEditTransactionModal({
    super.key,
    this.transaction,
    required this.onSave,
  });

  @override
  State<AddEditTransactionModal> createState() =>
      _AddEditTransactionModalState();
}

class _AddEditTransactionModalState extends State<AddEditTransactionModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descController;
  late TextEditingController _amountController;
  late TextEditingController _vendorController;
  late TextEditingController _dateController;

  int? _selectedCategoryId;
  String _paymentType = 'Cash'; // Cash or Credit
  String _needOrWant = 'Need'; // Need or Want

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _descController = TextEditingController(text: t?.description ?? '');
    _amountController = TextEditingController(
      text: t != null ? t.amount.toStringAsFixed(2) : '',
    );
    _vendorController = TextEditingController(text: t?.vendor ?? '');
    _dateController = TextEditingController(
      text: t != null ? t.date : DateFormatter.toIso(DateTime.now()),
    );

    _selectedCategoryId = t?.categoryId;
    _paymentType = t?.paymentType ?? 'Cash';
    _needOrWant = t?.needOrWant ?? 'Need';

    // Default select first available category if none selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catVm = Provider.of<CategoryViewModel>(context, listen: false);
      if (_selectedCategoryId == null && catVm.categories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = catVm.categories.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _vendorController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final current = DateFormatter.parseIso(_dateController.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormatter.toIso(picked);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final model = TransactionModel(
      id: widget.transaction?.id,
      description: _descController.text.trim(),
      categoryId: _selectedCategoryId!,
      date: _dateController.text.trim(),
      amount: amount,
      vendor: _vendorController.text.trim(),
      paymentType: _paymentType,
      needOrWant: _needOrWant,
    );

    widget.onSave(model);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final catVm = Provider.of<CategoryViewModel>(context);
    final isEditing = widget.transaction != null;
    final theme = Theme.of(context);
    final modalColor =
        theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = textPrimary.withValues(alpha: 0.65);
    final isDark = theme.brightness == Brightness.dark;
    final chipBorder = isDark
        ? AppColors.cardBorder
        : AppColors.lightCardBorder;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: modalColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Transaction' : 'Record Transaction',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Description',
                    hintText: 'e.g. Weekly Groceries, Fuel, Movie Ticket',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Enter description'
                      : null,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  initialValue:
                      catVm.categories.any((c) => c.id == _selectedCategoryId)
                      ? _selectedCategoryId
                      : (catVm.categories.isNotEmpty
                            ? catVm.categories.first.id
                            : null),
                  decoration: const InputDecoration(labelText: 'Category'),
                  dropdownColor: cardColor,
                  items: catVm.categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(cat.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            cat.name,
                            style: TextStyle(fontSize: 14, color: textPrimary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategoryId = val);
                  },
                  validator: (val) => val == null ? 'Select category' : null,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: InputDecoration(
                          labelText: 'Date of Transaction',
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount (\$)',
                          prefixText: '\$ ',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter amount';
                          }
                          if (double.tryParse(val.trim()) == null) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _vendorController,
                  decoration: InputDecoration(
                    labelText: 'Vendor / Merchant Name',
                    hintText: 'e.g. DeCA Commissary, AAFES Exchange, Chevron',
                    prefixIcon: Icon(Icons.store, color: textSecondary),
                  ),
                ),

                const SizedBox(height: 16),

                // Payment Type (Cash vs Credit)
                Text(
                  'PAYMENT TYPE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            'Cash / Debit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _paymentType == 'Cash'
                                  ? (isDark
                                      ? Colors.white
                                      : AppColors.lightTagCashText)
                                  : textPrimary,
                            ),
                          ),
                        ),
                        selected: _paymentType == 'Cash',
                        selectedColor: isDark
                            ? AppColors.statusGreen.withValues(alpha: 0.3)
                            : AppColors.lightTagCashBg,
                        side: BorderSide(
                          color: _paymentType == 'Cash'
                              ? (isDark
                                  ? AppColors.statusGreen
                                  : AppColors.lightTagCashText)
                              : chipBorder,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _paymentType = 'Cash');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            'Credit Card',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _paymentType == 'Credit'
                                  ? (isDark
                                      ? Colors.white
                                      : AppColors.lightTagCreditText)
                                  : textPrimary,
                            ),
                          ),
                        ),
                        selected: _paymentType == 'Credit',
                        selectedColor: isDark
                            ? AppColors.tagCredit.withValues(alpha: 0.3)
                            : AppColors.lightTagCreditBg,
                        side: BorderSide(
                          color: _paymentType == 'Credit'
                              ? (isDark
                                  ? AppColors.tagCredit
                                  : AppColors.lightTagCreditText)
                              : chipBorder,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _paymentType = 'Credit');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Classification (Need vs Want - Key AFAS Feature!)
                Text(
                  'CLASSIFICATION (NEED VS WANT)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.usafGold
                        : AppColors.lightUsafGoldText,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            'NEED (Essential)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _needOrWant == 'Need'
                                  ? (isDark
                                      ? Colors.white
                                      : AppColors.lightTagNeedText)
                                  : textPrimary,
                            ),
                          ),
                        ),
                        selected: _needOrWant == 'Need',
                        selectedColor: isDark
                            ? AppColors.tagNeed.withValues(alpha: 0.3)
                            : AppColors.lightTagNeedBg,
                        side: BorderSide(
                          color: _needOrWant == 'Need'
                              ? (isDark
                                  ? AppColors.tagNeed
                                  : AppColors.lightTagNeedText)
                              : chipBorder,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _needOrWant = 'Need');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            'WANT (Discretionary)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _needOrWant == 'Want'
                                  ? (isDark
                                      ? Colors.white
                                      : AppColors.lightTagWantText)
                                  : textPrimary,
                            ),
                          ),
                        ),
                        selected: _needOrWant == 'Want',
                        selectedColor: isDark
                            ? AppColors.tagWant.withValues(alpha: 0.3)
                            : AppColors.lightTagWantBg,
                        side: BorderSide(
                          color: _needOrWant == 'Want'
                              ? (isDark
                                  ? AppColors.tagWant
                                  : AppColors.lightTagWantText)
                              : chipBorder,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _needOrWant = 'Want');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      isEditing ? 'UPDATE TRANSACTION' : 'ADD TRANSACTION',
                    ),
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
