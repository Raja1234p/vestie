import 'package:vestie/core/utils/notification_time_formatter.dart';
import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:vestie/features/notifications/domain/entities/notification_list_entry.dart';

class AppNotificationModel extends AppNotificationEntity {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.type,
    super.isRead,
    super.createdAtUtc,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json.safeString('id'),
      title: json.safeString('title'),
      body: json.safeString('body'),
      type: json.safeString('type'),
      isRead: json.safeBool('isRead'),
      createdAtUtc: NotificationTimeFormatter.parseCreatedAtUtc(
        json.safeString('createdAtUtc', defaultValue: ''),
      ),
    );
  }

  NotificationListEntry toListEntry() {
    final label = NotificationTimeFormatter.format(createdAtUtc);
    return NotificationListEntry(
      id: id,
      title: title,
      body: body,
      timeLabel: label,
      isRead: isRead,
    );
  }
}

class NotificationsPageModel extends NotificationsPageEntity {
  const NotificationsPageModel({
    required super.notifications,
    super.unreadCount,
    super.page,
    super.pageSize,
    super.totalCount,
  });

  factory NotificationsPageModel.fromJson(Map<String, dynamic> json) {
    final list = (json['notifications'] as List<dynamic>?)
            ?.whereType<Map>()
            .map(
              (e) => AppNotificationModel.fromJson(e.cast<String, dynamic>()),
            )
            .toList(growable: false) ??
        const <AppNotificationModel>[];

    final pagination = json['pagination'];
    int page = 1;
    int pageSize = 20;
    int total = list.length;
    if (pagination is Map) {
      final p = pagination.cast<String, dynamic>();
      page = p.safeInt('page', defaultValue: 1);
      pageSize = p.safeInt('pageSize', defaultValue: 20);
      total = p.safeInt('totalCount', defaultValue: list.length);
    }

    return NotificationsPageModel(
      notifications: list,
      unreadCount: json.safeInt('unreadCount'),
      page: page,
      pageSize: pageSize,
      totalCount: total,
    );
  }
}
