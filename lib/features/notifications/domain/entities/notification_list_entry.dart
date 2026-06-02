import 'package:equatable/equatable.dart';

/// Single row in the notifications list (UI).
class NotificationListEntry extends Equatable {
  const NotificationListEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final bool isRead;

  NotificationListEntry copyWith({
    String? id,
    String? title,
    String? body,
    String? timeLabel,
    bool? isRead,
  }) {
    return NotificationListEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timeLabel: timeLabel ?? this.timeLabel,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, body, timeLabel, isRead];
}
