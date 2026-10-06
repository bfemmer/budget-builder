import '../../../../core/sqlite/database_helper.dart';
import '../../../../core/sqlite/tables.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<int> insertTransaction(TransactionModel transaction);
  Future<int> updateTransaction(TransactionModel transaction);
  Future<int> deleteTransaction(int id);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final DatabaseHelper dbHelper;

  TransactionLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final db = await dbHelper.database;
    final maps = await db.query(DbTables.transactions, orderBy: 'date DESC, id DESC');
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  @override
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;
    return await db.insert(DbTables.transactions, transaction.toMap());
  }

  @override
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;
    return await db.update(
      DbTables.transactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      DbTables.transactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
