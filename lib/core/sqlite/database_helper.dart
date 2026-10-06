import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'tables.dart';

class DatabaseHelper {
  static const _databaseName = "budget_builder.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, _databaseName);

    // Open/create database
    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Ensure settings table exists for existing databases
    await db.execute(DbTables.createSettingsTable.replaceAll('CREATE TABLE', 'CREATE TABLE IF NOT EXISTS'));

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DbTables.createProfileTable);
    await db.execute(DbTables.createCategoriesTable);
    await db.execute(DbTables.createTransactionsTable);
    await db.execute(DbTables.createNotificationsTable);
    await db.execute(DbTables.createSettingsTable);

    // Insert Default Profile
    await db.insert(DbTables.profile, DbTables.defaultProfile);

    // Insert Default USAF Categories
    for (var cat in DbTables.defaultCategories) {
      await db.insert(DbTables.categories, cat);
    }

    // Insert Default Theme Setting
    await db.insert(DbTables.settings, {
      'key': 'theme_mode',
      'value': 'dark',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration logic if schema changes in future versions
  }

  /// Close current database instance
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  /// Reset/Wipe database and re-seed default data
  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete(DbTables.transactions);
    await db.delete(DbTables.notifications);
    await db.delete(DbTables.categories);
    await db.delete(DbTables.profile);
    await db.delete(DbTables.settings);

    // Re-seed default profile, categories, and settings
    await db.insert(DbTables.profile, DbTables.defaultProfile);
    for (var cat in DbTables.defaultCategories) {
      await db.insert(DbTables.categories, cat);
    }
    await db.insert(DbTables.settings, {
      'key': 'theme_mode',
      'value': 'dark',
    });
  }
}
