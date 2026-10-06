import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository repository;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => !c.isIncome).toList();
  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.isIncome).toList();
  
  double get totalMonthlyLimit => expenseCategories.fold(
        0.0,
        (sum, cat) => sum + cat.monthlyLimit,
      );

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CategoryViewModel({required this.repository});

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await repository.getCategories();
      _categories = list.map((e) {
        if (e is CategoryModel) return e;
        return CategoryModel(
          id: e.id,
          name: e.name,
          monthlyLimit: e.monthlyLimit,
          iconName: e.iconName,
          colorValue: e.colorValue,
          isIncome: e.isIncome,
        );
      }).toList();
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(CategoryModel category) async {
    try {
      await repository.addCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add category: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await repository.updateCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update category: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await repository.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
      notifyListeners();
      return false;
    }
  }

  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
