import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../sqlite/database_helper.dart';
import '../sqlite/tables.dart';

class ThemeViewModel extends ChangeNotifier {
  final SharedPreferences prefs;
  final DatabaseHelper? dbHelper;

  static const String keyThemeMode = 'theme_mode';

  late ThemeMode _themeMode;
  final bool _isLoading = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLoading => _isLoading;

  ThemeViewModel({
    required this.prefs,
    this.dbHelper,
  }) {
    _initTheme();
  }

  void _initTheme() {
    final val = prefs.getString(keyThemeMode);
    if (val == 'light') {
      _themeMode = ThemeMode.light;
    } else if (val == 'system') {
      _themeMode = ThemeMode.system;
    } else if (val == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      // Default fallback if not set in SharedPreferences yet
      _themeMode = ThemeMode.dark;
      _migrateFromSqliteIfNeeded();
    }
  }

  Future<void> _migrateFromSqliteIfNeeded() async {
    if (dbHelper == null) return;
    try {
      final db = await dbHelper!.database;
      final maps = await db.query(
        DbTables.settings,
        where: 'key = ?',
        whereArgs: [keyThemeMode],
      );

      if (maps.isNotEmpty) {
        final val = maps.first['value'] as String?;
        if (val == 'light') {
          setThemeMode(ThemeMode.light);
        } else if (val == 'system') {
          setThemeMode(ThemeMode.system);
        } else if (val == 'dark') {
          setThemeMode(ThemeMode.dark);
        }
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    String val = 'dark';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.system) val = 'system';

    await prefs.setString(keyThemeMode, val);

    if (dbHelper != null) {
      try {
        final db = await dbHelper!.database;
        await db.insert(
          DbTables.settings,
          {'key': keyThemeMode, 'value': val},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (_) {}
    }
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
