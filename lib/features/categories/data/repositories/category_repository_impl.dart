import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await localDataSource.getCategories();
  }

  @override
  Future<int> addCategory(CategoryModel category) async {
    return await localDataSource.insertCategory(category);
  }

  @override
  Future<int> updateCategory(CategoryModel category) async {
    return await localDataSource.updateCategory(category);
  }

  @override
  Future<int> deleteCategory(int id) async {
    return await localDataSource.deleteCategory(id);
  }
}
