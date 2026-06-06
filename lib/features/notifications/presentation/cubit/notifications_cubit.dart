import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/utils/notification_time_formatter.dart';
import 'package:vestie/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:vestie/features/notifications/domain/entities/notification_list_entry.dart';
import 'package:vestie/features/notifications/domain/usecases/notifications_usecases.dart';

import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  static const int _pageSize = NotificationsState.defaultPageSize;

  final ListNotificationsUseCase listNotificationsUseCase;
  final MarkNotificationsReadUseCase markNotificationsReadUseCase;

  NotificationsCubit({
    required this.listNotificationsUseCase,
    required this.markNotificationsReadUseCase,
  }) : super(const NotificationsState(loading: true));

  Future<void> load() async {
    emit(
      state.copyWith(
        loading: true,
        loadingMore: false,
        silentRefreshing: false,
        clearError: true,
      ),
    );
    final result = await listNotificationsUseCase(page: 1, pageSize: _pageSize);
    result.fold(
      (failure) {
        emit(
          NotificationsState(
            loading: false,
            error: failure.message,
            pageSize: _pageSize,
          ),
        );
      },
      (page) => emit(_stateFromPage(page, replaceItems: true, loading: false)),
    );
  }

  Future<void> loadMore() async {
    if (state.loading ||
        state.loadingMore ||
        state.silentRefreshing ||
        !state.hasMore) {
      return;
    }

    emit(state.copyWith(loadingMore: true, clearError: true));
    final nextPage = state.currentPage + 1;
    final result = await listNotificationsUseCase(
      page: nextPage,
      pageSize: state.pageSize,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(loadingMore: false, error: failure.message));
      },
      (page) {
        final newItems = _mapNotifications(page.notifications);
        emit(
          state.copyWith(
            items: [...state.items, ...newItems],
            unreadCount: page.unreadCount,
            currentPage: page.page,
            pageSize: page.pageSize,
            totalCount: page.totalCount,
            loadingMore: false,
            clearError: true,
          ),
        );
      },
    );
  }

  /// Mark read on the server, then refresh the list (shows [NotificationsState.silentRefreshing] overlay).
  Future<void> markAsRead(String notificationId) async {
    if (notificationId.isEmpty || state.silentRefreshing) return;

    final index = state.items.indexWhere((e) => e.id == notificationId);
    if (index < 0 || state.items[index].isRead) return;

    emit(state.copyWith(silentRefreshing: true, clearError: true));

    final markResult = await markNotificationsReadUseCase([notificationId]);
    await markResult.fold((failure) async {
      emit(state.copyWith(silentRefreshing: false, error: failure.message));
    }, (_) async => _silentRefreshList());
  }

  Future<void> _silentRefreshList() async {
    final result = await listNotificationsUseCase(
      page: 1,
      pageSize: state.pageSize,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(silentRefreshing: false, error: failure.message));
      },
      (page) {
        emit(
          _stateFromPage(
            page,
            replaceItems: true,
            loading: false,
            silentRefreshing: false,
          ),
        );
      },
    );
  }

  NotificationsState _stateFromPage(
    NotificationsPageEntity page, {
    required bool replaceItems,
    required bool loading,
    bool silentRefreshing = false,
  }) {
    final items = _mapNotifications(page.notifications);
    return NotificationsState(
      items: replaceItems ? items : [...state.items, ...items],
      unreadCount: page.unreadCount,
      currentPage: page.page,
      pageSize: page.pageSize,
      totalCount: page.totalCount,
      loading: loading,
      loadingMore: false,
      silentRefreshing: silentRefreshing,
    );
  }

  List<NotificationListEntry> _mapNotifications(
    List<AppNotificationEntity> notifications,
  ) {
    return notifications
        .map(
          (n) => NotificationListEntry(
            id: n.id,
            title: n.title,
            body: n.body,
            timeLabel: NotificationTimeFormatter.format(n.createdAtUtc),
            isRead: n.isRead,
          ),
        )
        .toList(growable: false);
  }
}
