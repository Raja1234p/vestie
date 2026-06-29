import 'package:equatable/equatable.dart';

import '../../models/pagination_dto.dart';

/// Domain wrapper for a single paginated API page.
class PaginatedResult<T> extends Equatable {
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory PaginatedResult.fromPaginatedList(PaginatedListModel<T> model) {
    final pagination = model.pagination;
    return PaginatedResult(
      items: model.items,
      page: pagination.page,
      pageSize: pagination.pageSize,
      totalCount: pagination.totalCount,
      totalPages: pagination.totalPages,
    );
  }

  factory PaginatedResult.singlePage(List<T> items) {
    final count = items.length;
    return PaginatedResult(
      items: items,
      page: 1,
      pageSize: count == 0 ? PaginationQuery.defaultPageSize : count,
      totalCount: count,
      totalPages: count == 0 ? 0 : 1,
    );
  }

  PaginatedResult<T> appendPage(PaginatedResult<T> next) {
    return PaginatedResult(
      items: [...items, ...next.items],
      page: next.page,
      pageSize: next.pageSize,
      totalCount: next.totalCount,
      totalPages: next.totalPages,
    );
  }

  @override
  List<Object?> get props => [items, page, pageSize, totalCount, totalPages];
}
