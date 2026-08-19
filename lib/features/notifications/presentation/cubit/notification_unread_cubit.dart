import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/services/notifications/notification_unread_refresh.dart';
import 'package:vestie/features/notifications/domain/usecases/notifications_usecases.dart';

import 'notification_unread_state.dart';

/// App-wide unread count for the Home / Discover notification bell.
class NotificationUnreadCubit extends Cubit<NotificationUnreadState> {
  static const int _probePageSize = 1;

  final ListNotificationsUseCase listNotificationsUseCase;
  bool _refreshInFlight = false;

  NotificationUnreadCubit({
    required this.listNotificationsUseCase,
  }) : super(const NotificationUnreadState()) {
    NotificationUnreadRefresh.register(refresh);
  }

  /// Sync from inbox list responses without an extra GET.
  void setCount(int count) {
    if (count < 0 || state.unreadCount == count) return;
    emit(state.copyWith(unreadCount: count));
  }

  void reset() {
    emit(const NotificationUnreadState());
  }

  /// Lightweight probe — only [unreadCount] from `GET /notifications`.
  Future<void> refresh() async {
    if (_refreshInFlight) return;
    _refreshInFlight = true;
    try {
      final result = await listNotificationsUseCase(
        page: 1,
        pageSize: _probePageSize,
      );
      result.fold(
        (_) {},
        (page) => emit(state.copyWith(unreadCount: page.unreadCount)),
      );
    } finally {
      _refreshInFlight = false;
    }
  }

  @override
  Future<void> close() {
    NotificationUnreadRefresh.unregister();
    return super.close();
  }
}
