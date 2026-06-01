import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_list_entry.dart';

class NotificationsState extends Equatable {
  final List<NotificationListEntry> items;
  final bool loading;
  final int unreadCount;
  final String? error;

  const NotificationsState({
    this.items = const [],
    this.loading = false,
    this.unreadCount = 0,
    this.error,
  });

  bool get hasLoadError =>
      error != null && items.isEmpty && !loading;

  bool get isEmptySuccess =>
      error == null && items.isEmpty && !loading;

  NotificationsState copyWith({
    List<NotificationListEntry>? items,
    bool? loading,
    int? unreadCount,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      unreadCount: unreadCount ?? this.unreadCount,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [items, loading, unreadCount, error];
}
