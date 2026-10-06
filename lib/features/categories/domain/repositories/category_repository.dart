import '../entities/category.dart';
import '../../data/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<int> addCategory(CategoryModel category);
  Future<int> updateCategory(CategoryModel category);
  Future<int> deleteCategory(int id);
}
