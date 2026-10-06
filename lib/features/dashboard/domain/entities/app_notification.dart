class AppNotification {
  final int? id;
  final String title;
  final String message;
  final int? categoryId;
  final String timestamp;
  final bool isRead;

  AppNotification({
    this.id,
    required this.title,
    required this.message,
    this.categoryId,
    required this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      categoryId: map['category_id'],
      timestamp: map['timestamp'] ?? '',
      isRead: (map['is_read'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'message': message,
      'category_id': categoryId,
      'timestamp': timestamp,
      'is_read': isRead ? 1 : 0,
    };
  }
}
