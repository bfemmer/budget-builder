import 'package:sqflite/sqflite.dart';

import '../../../../core/sqlite/database_helper.dart';
import '../../../../core/sqlite/tables.dart';
import '../../domain/entities/app_notification.dart';

class NotificationLocalDataSource {
  final DatabaseHelper dbHelper;

  NotificationLocalDataSource({required this.dbHelper});

  Future<List<AppNotification>> getNotifications() async {
    final db = await dbHelper.database;
    final maps = await db.query(DbTables.notifications, orderBy: 'id DESC');
    return maps.map((m) => AppNotification.fromMap(m)).toList();
  }

  Future<int> getUnreadCount() async {
    final db = await dbHelper.database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbTables.notifications} WHERE is_read = 0',
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<void> addNotification({
    required String title,
    required String message,
    int? categoryId,
  }) async {
    final db = await dbHelper.database;

    // Check if duplicate notification exists recently to avoid clutter
    final existing = await db.query(
      DbTables.notifications,
      where: 'title = ? AND message = ? AND is_read = 0',
      whereArgs: [title, message],
    );
    if (existing.isNotEmpty) return;

    final n = AppNotification(
      title: title,
      message: message,
      categoryId: categoryId,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
    );
    await db.insert(DbTables.notifications, n.toMap());
  }

  Future<void> markAsRead(int id) async {
    final db = await dbHelper.database;
    await db.update(
      DbTables.notifications,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final db = await dbHelper.database;
    await db.delete(DbTables.notifications);
  }
}
