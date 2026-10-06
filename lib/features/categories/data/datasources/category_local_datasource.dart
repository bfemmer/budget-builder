import '../../../../core/sqlite/database_helper.dart';
import '../../../../core/sqlite/tables.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<int> insertCategory(CategoryModel category);
  Future<int> updateCategory(CategoryModel category);
  Future<int> deleteCategory(int id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseHelper dbHelper;

  CategoryLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final db = await dbHelper.database;
    final maps = await db.query(DbTables.categories, orderBy: 'name ASC');
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<int> insertCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    return await db.insert(DbTables.categories, category.toMap());
  }

  @override
  Future<int> updateCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    return await db.update(
      DbTables.categories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<int> deleteCategory(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      DbTables.categories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
