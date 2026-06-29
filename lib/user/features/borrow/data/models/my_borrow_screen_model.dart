import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';

class MyBorrowScreenModel {
  final MyBorrowCurrentRequestModel? currentRequest;
  final List<MyBorrowHistoryItemModel> history;
  final PaginationDto historyPagination;

  const MyBorrowScreenModel({
    this.currentRequest,
    this.history = const [],
    required this.historyPagination,
  });

  factory MyBorrowScreenModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['currentRequest'];
    final historyParsed = PaginatedListParser.parse(
      json['history'],
      MyBorrowHistoryItemModel.fromJson,
    );

    return MyBorrowScreenModel(
      currentRequest: currentJson is Map
          ? MyBorrowCurrentRequestModel.fromJson(currentJson.cast())
          : null,
      history: historyParsed.items,
      historyPagination: historyParsed.pagination,
    );
  }
}

class MyBorrowCurrentRequestModel {
  final String id;
  final double requestedAmount;
  final String currency;
  final String status;
  final String statusDisplay;
  final int memberVotesAgree;
  final int memberVotesDisagree;
  final String? dueAtUtc;
  final String dueByDisplay;
  final String? createdAtUtc;

  const MyBorrowCurrentRequestModel({
    required this.id,
    required this.requestedAmount,
    required this.currency,
    required this.status,
    required this.statusDisplay,
    required this.memberVotesAgree,
    required this.memberVotesDisagree,
    this.dueAtUtc,
    required this.dueByDisplay,
    this.createdAtUtc,
  });

  factory MyBorrowCurrentRequestModel.fromJson(Map<String, dynamic> json) {
    return MyBorrowCurrentRequestModel(
      id: (json['id'] as String?) ?? '',
      requestedAmount: (json['requestedAmount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'USD',
      status: (json['status'] as String?) ?? '',
      statusDisplay: (json['statusDisplay'] as String?) ?? '',
      memberVotesAgree: (json['memberVotesAgree'] as num?)?.toInt() ?? 0,
      memberVotesDisagree: (json['memberVotesDisagree'] as num?)?.toInt() ?? 0,
      dueAtUtc: json['dueAtUtc'] as String?,
      dueByDisplay: (json['dueByDisplay'] as String?) ?? '',
      createdAtUtc: json['createdAtUtc'] as String?,
    );
  }

  BorrowRequestEntity toEntity() {
    return BorrowRequestEntity(
      id: id,
      initials: 'ME',
      memberName: 'You',
      loanType: statusDisplay,
      requestedAmount: requestedAmount,
      upvotes: memberVotesAgree,
      downvotes: memberVotesDisagree,
      status: status,
    );
  }

  MyBorrowHistoryEntry toHistoryEntry() {
    return MyBorrowHistoryItemModel(
      id: id,
      requestedAmount: requestedAmount,
      currency: currency,
      status: status,
      statusDisplay: statusDisplay,
      createdAtUtc: createdAtUtc,
    ).toHistoryEntry();
  }
}

class MyBorrowHistoryItemModel {
  final String id;
  final double requestedAmount;
  final String currency;
  final String status;
  final String statusDisplay;
  final String? createdAtUtc;

  const MyBorrowHistoryItemModel({
    required this.id,
    required this.requestedAmount,
    required this.currency,
    required this.status,
    required this.statusDisplay,
    this.createdAtUtc,
  });

  factory MyBorrowHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return MyBorrowHistoryItemModel(
      id: (json['id'] as String?) ?? '',
      requestedAmount: (json['requestedAmount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'USD',
      status: (json['status'] as String?) ?? '',
      statusDisplay: (json['statusDisplay'] as String?) ?? '',
      createdAtUtc: json['createdAtUtc'] as String?,
    );
  }

  MyBorrowHistoryEntry toHistoryEntry() {
    final approved = status == 'Approved' || status == 'Disbursed' || status == 'Repaid';
    return MyBorrowHistoryEntry(
      id: id,
      amount: requestedAmount,
      dateLabel: _formatDateLabel(createdAtUtc),
      isApproved: approved,
      status: status,
      statusDisplay: statusDisplay,
    );
  }

  static String _formatDateLabel(String? utc) {
    if (utc == null || utc.isEmpty) return '';
    final parsed = DateTime.tryParse(utc);
    if (parsed == null) return utc;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.day}';
  }
}
