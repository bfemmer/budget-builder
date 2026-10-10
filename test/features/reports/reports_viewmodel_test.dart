import 'package:flutter_test/flutter_test.dart';
import 'package:budget/features/reports/presentation/viewmodels/reports_viewmodel.dart';
import 'package:budget/features/categories/presentation/viewmodels/category_viewmodel.dart';
import 'package:budget/features/categories/data/models/category_model.dart';
import 'package:budget/features/categories/domain/repositories/category_repository.dart';
import 'package:budget/features/transactions/data/models/transaction_model.dart';
import 'package:budget/features/transactions/domain/entities/transaction_entity.dart';
import 'package:budget/features/transactions/domain/repositories/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  final List<TransactionModel> transactions;
  MockTransactionRepository(this.transactions);

  @override
  Future<List<TransactionEntity>> getTransactions() async => transactions;

  @override
  Future<int> addTransaction(TransactionModel transaction) async => 1;

  @override
  Future<int> updateTransaction(TransactionModel transaction) async => 1;

  @override
  Future<int> deleteTransaction(int id) async => 1;
}

class MockCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryModel>> getCategories() async => [
    CategoryModel(
      id: 1,
      name: 'Food',
      monthlyLimit: 500.0,
      colorValue: 0xFF0000FF,
      isIncome: false,
    ),
    CategoryModel(
      id: 2,
      name: 'Salary',
      monthlyLimit: 0.0,
      colorValue: 0xFF00FF00,
      isIncome: true,
    ),
  ];
  @override
  Future<int> addCategory(CategoryModel category) async => 1;
  @override
  Future<int> updateCategory(CategoryModel category) async => 1;
  @override
  Future<int> deleteCategory(int id) async => 1;
  Future<void> reorderCategories(List<CategoryModel> categories) async {}
}

void main() {
  test(
    'ReportsViewModel filters transactions by specific month correctly',
    () async {
      final mockTxList = [
        TransactionModel(
          id: 1,
          description: 'May Coffee',
          categoryId: 1,
          date: '2026-05-15',
          amount: 5.50,
          vendor: 'Starbucks',
          paymentType: 'Card',
          needOrWant: 'Want',
        ),
        TransactionModel(
          id: 2,
          description: 'May Paycheck',
          categoryId: 2,
          date: '2026-05-01',
          amount: 2000.00,
          vendor: 'Employer',
          paymentType: 'Transfer',
          needOrWant: 'Need',
        ),
        TransactionModel(
          id: 3,
          description: 'June Groceries',
          categoryId: 1,
          date: '2026-06-10',
          amount: 150.00,
          vendor: 'Supermarket',
          paymentType: 'Card',
          needOrWant: 'Need',
        ),
      ];

      final txRepo = MockTransactionRepository(mockTxList);
      final catRepo = MockCategoryRepository();
      final reportsVm = ReportsViewModel(repository: txRepo);
      final catVm = CategoryViewModel(repository: catRepo);
      await catVm.loadCategories();
      await reportsVm.loadReportData();

      // Select May 2026
      reportsVm.setSelectedMonth(DateTime(2026, 5));

      expect(reportsVm.selectedTimeframe, ReportTimeframe.specificMonth);
      expect(reportsVm.selectedMonth, DateTime(2026, 5));

      final filtered = reportsVm.getFilteredTransactions();
      expect(filtered.length, 2);
      expect(filtered.every((t) => t.date.startsWith('2026-05')), isTrue);

      final totalExpenses = reportsVm.getTotalExpenses(catVm);
      expect(totalExpenses, 5.50);

      final totalIncome = reportsVm.getTotalIncome(catVm);
      expect(totalIncome, 2000.00);

      final netCashFlow = reportsVm.getNetCashFlow(catVm);
      expect(netCashFlow, 1994.50);

      // Now select June 2026
      reportsVm.setSelectedMonth(DateTime(2026, 6));
      expect(reportsVm.getTotalExpenses(catVm), 150.00);
      expect(reportsVm.getTotalIncome(catVm), 0.0);
    },
  );
}
