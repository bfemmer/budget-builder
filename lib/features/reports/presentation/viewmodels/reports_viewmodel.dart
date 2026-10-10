import 'package:flutter/material.dart';
import '../../../categories/presentation/viewmodels/category_viewmodel.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

enum ReportTimeframe { last7Days, lastMonth, yearToDate, specificMonth }

class ReportsViewModel extends ChangeNotifier {
  final TransactionRepository repository;

  ReportTimeframe _selectedTimeframe = ReportTimeframe.lastMonth;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;

  ReportTimeframe get selectedTimeframe => _selectedTimeframe;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  ReportsViewModel({required this.repository});

  void setTimeframe(ReportTimeframe timeframe) {
    _selectedTimeframe = timeframe;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    _selectedTimeframe = ReportTimeframe.specificMonth;
    notifyListeners();
  }

  Future<void> loadReportData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<TransactionEntity> list = await repository.getTransactions();
      _allTransactions = list.map((e) {
        if (e is TransactionModel) return e;
        return TransactionModel(
          id: e.id,
          description: e.description,
          categoryId: e.categoryId,
          date: e.date,
          amount: e.amount,
          vendor: e.vendor,
          paymentType: e.paymentType,
          needOrWant: e.needOrWant,
        );
      }).toList();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TransactionModel> getFilteredTransactions([List<TransactionModel>? transactions]) {
    final source = transactions ?? _allTransactions;
    final now = DateTime.now();
    return source.where((t) {
      final date = DateTime.tryParse(t.date);
      if (date == null) return false;

      switch (_selectedTimeframe) {
        case ReportTimeframe.last7Days:
          final diff = now.difference(date).inDays;
          return diff >= 0 && diff <= 7;
        case ReportTimeframe.lastMonth:
          final lastMonthDate = DateTime(now.year, now.month - 1, now.day);
          return date.isAfter(lastMonthDate) && date.isBefore(now.add(const Duration(days: 1)));
        case ReportTimeframe.yearToDate:
          return date.year == now.year;
        case ReportTimeframe.specificMonth:
          return date.year == _selectedMonth.year && date.month == _selectedMonth.month;
      }
    }).toList();
  }

  /// Get expense transactions only (where category is not income)
  List<TransactionModel> getExpenseTransactions(
    CategoryViewModel categoryViewModel, [
    List<TransactionModel>? transactions,
  ]) {
    return getFilteredTransactions(transactions).where((t) {
      final cat = categoryViewModel.getCategoryById(t.categoryId);
      return cat == null || !cat.isIncome;
    }).toList();
  }

  /// Get income transactions only
  List<TransactionModel> getIncomeTransactions(
    CategoryViewModel categoryViewModel, [
    List<TransactionModel>? transactions,
  ]) {
    return getFilteredTransactions(transactions).where((t) {
      final cat = categoryViewModel.getCategoryById(t.categoryId);
      return cat != null && cat.isIncome;
    }).toList();
  }

  double getTotalExpenses(
    CategoryViewModel categoryViewModel, [
    List<TransactionModel>? transactions,
  ]) {
    return getExpenseTransactions(categoryViewModel, transactions)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalIncome(
    CategoryViewModel categoryViewModel, [
    List<TransactionModel>? transactions,
  ]) {
    return getIncomeTransactions(categoryViewModel, transactions)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getNetCashFlow(
    CategoryViewModel categoryViewModel, [
    List<TransactionModel>? transactions,
  ]) {
    return getTotalIncome(categoryViewModel, transactions) -
        getTotalExpenses(categoryViewModel, transactions);
  }

  double getNeedsExpenses(
    CategoryViewModel categoryViewModel, [
    List<TransactionModel>? transactions,
  ]) {
    return getExpenseTransactions(categoryViewModel, transactions)
        .where((t) => t.needOrWant == 'Need')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getWantsExpenses(
    CategoryViewModel categoryViewModel, [
    List<TransactionModel>? transactions,
  ]) {
    return getExpenseTransactions(categoryViewModel, transactions)
        .where((t) => t.needOrWant == 'Want')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<int, double> getExpenseCategoryMap(
    CategoryViewModel categoryViewModel, [
    List<TransactionModel>? transactions,
  ]) {
    final Map<int, double> map = {};
    for (var t in getExpenseTransactions(categoryViewModel, transactions)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0.0) + t.amount;
    }
    return map;
  }

  Map<int, double> getIncomeCategoryMap(
    CategoryViewModel categoryViewModel, [
    List<TransactionModel>? transactions,
  ]) {
    final Map<int, double> map = {};
    for (var t in getIncomeTransactions(categoryViewModel, transactions)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0.0) + t.amount;
    }
    return map;
  }
}
