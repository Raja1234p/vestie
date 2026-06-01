import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/features/notifications/domain/entities/notification_list_entry.dart';
import 'package:vestie/features/notifications/domain/usecases/notifications_usecases.dart';

import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final ListNotificationsUseCase listNotificationsUseCase;
  final MarkNotificationsReadUseCase markNotificationsReadUseCase;

  NotificationsCubit({
    required this.listNotificationsUseCase,
    required this.markNotificationsReadUseCase,
  }) : super(const NotificationsState(loading: true));

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    final result = await listNotificationsUseCase();
    result.fold(
      (failure) {
        emit(NotificationsState(
          loading: false,
          error: failure.message,
        ));
      },
      (page) {
        final items = page.notifications
            .map((n) => NotificationListEntry(
                  id: n.id,
                  title: n.title,
                  body: n.body,
                  timeLabel: _formatTime(n.createdAtUtc),
                  isRead: n.isRead,
                ))
            .toList(growable: false);
        emit(NotificationsState(
          items: items,
          unreadCount: page.unreadCount,
          loading: false,
        ));
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    if (notificationId.isEmpty) return;

    final index = state.items.indexWhere((e) => e.id == notificationId);
    if (index < 0 || state.items[index].isRead) return;

    final result = await markNotificationsReadUseCase([notificationId]);
    result.fold(
      (_) {},
      (_) {
        final updated = state.items
            .map(
              (e) => e.id == notificationId
                  ? NotificationListEntry(
                      id: e.id,
                      title: e.title,
                      body: e.body,
                      timeLabel: e.timeLabel,
                      isRead: true,
                    )
                  : e,
            )
            .toList(growable: false);
        final unread = updated.where((e) => !e.isRead).length;
        emit(state.copyWith(items: updated, unreadCount: unread));
      },
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    return '${local.month}/${local.day}';
  }
}
