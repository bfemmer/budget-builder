import 'package:flutter/material.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

enum ReportTimeframe { last7Days, lastMonth, yearToDate }

class ReportsViewModel extends ChangeNotifier {
  final TransactionRepository repository;

  ReportTimeframe _selectedTimeframe = ReportTimeframe.lastMonth;
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;

  ReportTimeframe get selectedTimeframe => _selectedTimeframe;
  bool get isLoading => _isLoading;

  ReportsViewModel({required this.repository});

  void setTimeframe(ReportTimeframe timeframe) {
    _selectedTimeframe = timeframe;
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

  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();
    return _allTransactions.where((t) {
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
      }
    }).toList();
  }

  double get totalSpentInTimeframe {
    return filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalNeedsInTimeframe {
    return filteredTransactions
        .where((t) => t.needOrWant == 'Need')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalWantsInTimeframe {
    return filteredTransactions
        .where((t) => t.needOrWant == 'Want')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<int, double> get categorySpendingMap {
    final Map<int, double> map = {};
    for (var t in filteredTransactions) {
      map[t.categoryId] = (map[t.categoryId] ?? 0.0) + t.amount;
    }
    return map;
  }
}
