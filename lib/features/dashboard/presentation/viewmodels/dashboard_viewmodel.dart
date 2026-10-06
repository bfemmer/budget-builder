import 'package:budget/features/dashboard/data/datasources/notification_local_datasource.dart';
import 'package:budget/features/dashboard/domain/entities/app_notification.dart';
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  final NotificationLocalDataSource notificationDataSource;

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  DashboardViewModel({required this.notificationDataSource});

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await notificationDataSource.getNotifications();
      _unreadCount = await notificationDataSource.getUnreadCount();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    await notificationDataSource.markAsRead(id);
    await loadNotifications();
  }

  Future<void> clearAllNotifications() async {
    await notificationDataSource.clearAll();
    await loadNotifications();
  }
}
