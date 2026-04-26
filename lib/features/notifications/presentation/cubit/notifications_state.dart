import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_list_entry.dart';

class NotificationsState extends Equatable {
  const NotificationsState({this.items = const []});

  final List<NotificationListEntry> items;

  @override
  List<Object?> get props => [items];
}
