import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../sqlite/database_helper.dart';
import '../sqlite/tables.dart';

class ThemeViewModel extends ChangeNotifier {
  final DatabaseHelper dbHelper;

  ThemeMode _themeMode = ThemeMode.dark;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLoading => _isLoading;

  ThemeViewModel({required this.dbHelper}) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await dbHelper.database;
      final maps = await db.query(
        DbTables.settings,
        where: 'key = ?',
        whereArgs: ['theme_mode'],
      );

      if (maps.isNotEmpty) {
        final val = maps.first['value'] as String?;
        if (val == 'light') {
          _themeMode = ThemeMode.light;
        } else if (val == 'system') {
          _themeMode = ThemeMode.system;
        } else {
          _themeMode = ThemeMode.dark;
        }
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final db = await dbHelper.database;
      String val = 'dark';
      if (mode == ThemeMode.light) val = 'light';
      if (mode == ThemeMode.system) val = 'system';

      await db.insert(
        DbTables.settings,
        {'key': 'theme_mode', 'value': val},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
