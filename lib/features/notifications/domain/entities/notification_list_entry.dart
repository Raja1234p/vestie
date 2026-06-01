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

  @override
  List<Object?> get props => [id, title, body, timeLabel, isRead];
}
