import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/sqlite/database_helper.dart';
import '../../../../core/sqlite/tables.dart';

class BackupRestoreDataSource {
  final DatabaseHelper dbHelper;

  BackupRestoreDataSource({required this.dbHelper});

  /// Export full database to JSON Map
  Future<Map<String, dynamic>> exportDataToMap() async {
    final db = await dbHelper.database;

    final profileData = await db.query(DbTables.profile);
    final categoriesData = await db.query(DbTables.categories);
    final transactionsData = await db.query(DbTables.transactions);
    final notificationsData = await db.query(DbTables.notifications);

    return {
      'app': 'AFAS Budget Builder',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'profile': profileData.isNotEmpty ? profileData.first : {},
      'categories': categoriesData,
      'transactions': transactionsData,
      'notifications': notificationsData,
    };
  }

  /// Export data as formatted JSON string
  Future<String> exportToJsonString() async {
    final map = await exportDataToMap();
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Export data to a JSON file in local App Documents Directory
  Future<File> exportToJsonFile() async {
    final jsonStr = await exportToJsonString();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/budget_builder_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    return await file.writeAsString(jsonStr);
  }

  /// Import database from JSON map string
  Future<bool> importFromJsonString(String jsonStr) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      final db = await dbHelper.database;

      await db.transaction((txn) async {
        // Clear existing tables
        await txn.delete(DbTables.transactions);
        await txn.delete(DbTables.notifications);
        await txn.delete(DbTables.categories);
        await txn.delete(DbTables.profile);

        // Import Profile
        if (data['profile'] != null && data['profile'] is Map) {
          final profileMap = Map<String, dynamic>.from(data['profile']);
          await txn.insert(DbTables.profile, profileMap);
        }

        // Import Categories
        if (data['categories'] != null && data['categories'] is List) {
          for (var item in data['categories']) {
            final catMap = Map<String, dynamic>.from(item);
            await txn.insert(DbTables.categories, catMap);
          }
        }

        // Import Transactions
        if (data['transactions'] != null && data['transactions'] is List) {
          for (var item in data['transactions']) {
            final txMap = Map<String, dynamic>.from(item);
            await txn.insert(DbTables.transactions, txMap);
          }
        }

        // Import Notifications
        if (data['notifications'] != null && data['notifications'] is List) {
          for (var item in data['notifications']) {
            final nMap = Map<String, dynamic>.from(item);
            await txn.insert(DbTables.notifications, nMap);
          }
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
