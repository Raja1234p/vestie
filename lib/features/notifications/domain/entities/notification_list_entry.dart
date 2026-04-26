import 'package:equatable/equatable.dart';

/// Single row in the notifications list (UI / future API model).
class NotificationListEntry extends Equatable {
  const NotificationListEntry({
    required this.title,
    required this.body,
    required this.timeLabel,
  });

  final String title;
  final String body;
  final String timeLabel;

  @override
  List<Object?> get props => [title, body, timeLabel];
}
