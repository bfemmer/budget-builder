import 'package:flutter_test/flutter_test.dart';
import 'package:budget/features/reports/utils/pdf_report_generator.dart';
import 'package:budget/features/categories/presentation/viewmodels/category_viewmodel.dart';
import 'package:budget/features/categories/data/models/category_model.dart';
import 'package:budget/features/categories/domain/repositories/category_repository.dart';
import 'package:budget/features/transactions/data/models/transaction_model.dart';

class MockCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryModel>> getCategories() async => [
    CategoryModel(
      id: 1,
      name: 'Dining Out',
      monthlyLimit: 200.0,
      colorValue: 0xFF0000FF,
      isIncome: false,
    ),
    CategoryModel(
      id: 2,
      name: 'Paycheck',
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
  test('PdfReportGenerator generates valid PDF bytes', () async {
    final catRepo = MockCategoryRepository();
    final catVm = CategoryViewModel(repository: catRepo);
    await catVm.loadCategories();

    final mockTxList = [
      TransactionModel(
        id: 1,
        description: 'Lunch',
        categoryId: 1,
        date: '2026-10-05',
        amount: 25.00,
        vendor: 'Diner',
        paymentType: 'Card',
        needOrWant: 'Want',
      ),
      TransactionModel(
        id: 2,
        description: 'Salary',
        categoryId: 2,
        date: '2026-10-01',
        amount: 3000.00,
        vendor: 'Company',
        paymentType: 'Transfer',
        needOrWant: 'Need',
      ),
    ];

    final pdfBytes = await PdfReportGenerator.generate(
      timeframeLabel: 'October 2026',
      totalIncome: 3000.00,
      totalExpenses: 25.00,
      netCashFlow: 2975.00,
      needsSpent: 0.0,
      wantsSpent: 25.00,
      expenseCategoryMap: {1: 25.00},
      incomeCategoryMap: {2: 3000.00},
      transactions: mockTxList,
      catVm: catVm,
    );

    expect(pdfBytes, isNotEmpty);
    // Check PDF header signature bytes '%PDF-'
    final headerStr = String.fromCharCodes(pdfBytes.take(5));
    expect(headerStr, '%PDF-');
  });
}
