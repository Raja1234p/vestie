import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_list_entry.dart';

class NotificationsState extends Equatable {
  static const int defaultPageSize = 20;

  final List<NotificationListEntry> items;
  final bool loading;
  final bool loadingMore;
  final bool silentRefreshing;
  final int unreadCount;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final String? error;

  const NotificationsState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.silentRefreshing = false,
    this.unreadCount = 0,
    this.currentPage = 0,
    this.pageSize = defaultPageSize,
    this.totalCount = 0,
    this.error,
  });

  bool get hasLoadError => error != null && items.isEmpty && !loading;

  bool get isEmptySuccess =>
      error == null && items.isEmpty && !loading && !silentRefreshing;

  bool get hasMore => items.length < totalCount;

  NotificationsState copyWith({
    List<NotificationListEntry>? items,
    bool? loading,
    bool? loadingMore,
    bool? silentRefreshing,
    int? unreadCount,
    int? currentPage,
    int? pageSize,
    int? totalCount,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      silentRefreshing: silentRefreshing ?? this.silentRefreshing,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        items,
        loading,
        loadingMore,
        silentRefreshing,
        unreadCount,
        currentPage,
        pageSize,
        totalCount,
        error,
      ];
}
