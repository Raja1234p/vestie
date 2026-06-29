import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/domain/entities/pagination_info.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';

class MyBorrowScreenEntity {
  final BorrowRequestEntity? activeRequest;
  final List<MyBorrowHistoryEntry> history;
  final PaginationInfo historyPagination;

  const MyBorrowScreenEntity({
    this.activeRequest,
    this.history = const [],
    required this.historyPagination,
  });
}
