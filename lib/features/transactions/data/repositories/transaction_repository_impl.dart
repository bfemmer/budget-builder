import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    return await localDataSource.getTransactions();
  }

  @override
  Future<int> addTransaction(TransactionModel transaction) async {
    return await localDataSource.insertTransaction(transaction);
  }

  @override
  Future<int> updateTransaction(TransactionModel transaction) async {
    return await localDataSource.updateTransaction(transaction);
  }

  @override
  Future<int> deleteTransaction(int id) async {
    return await localDataSource.deleteTransaction(id);
  }
}
