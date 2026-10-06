import '../entities/transaction_entity.dart';
import '../../data/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<int> addTransaction(TransactionModel transaction);
  Future<int> updateTransaction(TransactionModel transaction);
  Future<int> deleteTransaction(int id);
}
