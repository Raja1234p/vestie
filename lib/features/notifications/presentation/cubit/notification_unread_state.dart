import 'package:equatable/equatable.dart';

class NotificationUnreadState extends Equatable {
  final int unreadCount;

  const NotificationUnreadState({this.unreadCount = 0});

  NotificationUnreadState copyWith({int? unreadCount}) {
    return NotificationUnreadState(
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [unreadCount];
}
