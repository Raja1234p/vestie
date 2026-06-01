import 'package:equatable/equatable.dart';

class AppNotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime? createdAtUtc;

  const AppNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.type = '',
    this.isRead = false,
    this.createdAtUtc,
  });

  @override
  List<Object?> get props => [id, title, body, type, isRead, createdAtUtc];
}

class NotificationsPageEntity extends Equatable {
  final List<AppNotificationEntity> notifications;
  final int unreadCount;
  final int page;
  final int pageSize;
  final int totalCount;

  const NotificationsPageEntity({
    required this.notifications,
    this.unreadCount = 0,
    this.page = 1,
    this.pageSize = 20,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props =>
      [notifications, unreadCount, page, pageSize, totalCount];
}
