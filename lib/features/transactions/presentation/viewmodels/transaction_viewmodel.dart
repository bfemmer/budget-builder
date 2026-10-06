import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../categories/presentation/viewmodels/category_viewmodel.dart';
import '../../../dashboard/data/datasources/notification_local_datasource.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository repository;
  final NotificationLocalDataSource? notificationDataSource;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TransactionViewModel({
    required this.repository,
    this.notificationDataSource,
  });

  Future<void> loadTransactions([CategoryViewModel? categoryViewModel]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await repository.getTransactions();
      _transactions = list.map((e) {
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

      if (categoryViewModel != null && notificationDataSource != null) {
        await _checkCategorySpendingLimits(categoryViewModel);
      }
    } catch (e) {
      _errorMessage = 'Failed to load transactions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(
    TransactionModel transaction, [
    CategoryViewModel? categoryViewModel,
  ]) async {
    try {
      await repository.addTransaction(transaction);
      await loadTransactions(categoryViewModel);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add transaction: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(
    TransactionModel transaction, [
    CategoryViewModel? categoryViewModel,
  ]) async {
    try {
      await repository.updateTransaction(transaction);
      await loadTransactions(categoryViewModel);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update transaction: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(
    int id, [
    CategoryViewModel? categoryViewModel,
  ]) async {
    try {
      await repository.deleteTransaction(id);
      await loadTransactions(categoryViewModel);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete transaction: $e';
      notifyListeners();
      return false;
    }
  }

  double getSpentForCategory(int categoryId) {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.categoryId == categoryId)
        .where((t) {
          final d = DateTime.tryParse(t.date);
          return d != null && d.month == now.month && d.year == now.year;
        })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalSpentCurrentMonth {
    final now = DateTime.now();
    return _transactions
        .where((t) {
          final d = DateTime.tryParse(t.date);
          return d != null && d.month == now.month && d.year == now.year;
        })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Check limits and post notification if spending limit exceeded
  Future<void> _checkCategorySpendingLimits(CategoryViewModel categoryViewModel) async {
    if (notificationDataSource == null) return;

    for (var cat in categoryViewModel.expenseCategories) {
      if (cat.id == null || cat.monthlyLimit <= 0) continue;

      final spent = getSpentForCategory(cat.id!);
      final ratio = spent / cat.monthlyLimit;

      if (ratio >= 1.0) {
        final percent = (ratio * 100).toInt();
        await notificationDataSource!.addNotification(
          title: 'Spending Limit Exceeded!',
          message: 'Spent amount exceeded $percent% for category "${cat.name}".',
          categoryId: cat.id,
        );
      } else if (ratio >= 0.8) {
        await notificationDataSource!.addNotification(
          title: 'Category Warning (80%+)',
          message: 'You have reached 80% of your limit for "${cat.name}".',
          categoryId: cat.id,
        );
      }
    }
  }
}
