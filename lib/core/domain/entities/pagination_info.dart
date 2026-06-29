import 'package:equatable/equatable.dart';

/// Domain pagination metadata without list items.
class PaginationInfo extends Equatable {
  const PaginationInfo({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [page, pageSize, totalCount, totalPages];
}
