import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/user/features/vff/presentation/mappers/user_vff_profile_mapper.dart';

class BorrowRequestListResponseModel {
  final List<BorrowRequestListItemModel> borrowRequests;
  final int totalCount;

  const BorrowRequestListResponseModel({
    required this.borrowRequests,
    required this.totalCount,
  });

  factory BorrowRequestListResponseModel.fromJson(Map<String, dynamic> json) {
    final items =
        (json['borrowRequests'] as List?)
            ?.whereType<Map>()
            .map((m) => BorrowRequestListItemModel.fromJson(m.cast()))
            .toList(growable: false) ??
        const <BorrowRequestListItemModel>[];

    return BorrowRequestListResponseModel(
      borrowRequests: items,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? items.length,
    );
  }
}

class BorrowRequestListItemModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberUsername;
  final String? memberPhotoUrl;
  final String reason;
  final double requestedAmount;
  final int upvoteCount;
  final int downvoteCount;
  final String? callerVote;
  final String status;
  final String? dueByUtc;
  final double? penaltyPercentage;
  final String? createdAtUtc;
  final String? requesterRole;
  final String? requiredDecisionBy;
  final bool callerCanDecide;

  const BorrowRequestListItemModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberUsername,
    this.memberPhotoUrl,
    required this.reason,
    required this.requestedAmount,
    required this.upvoteCount,
    required this.downvoteCount,
    this.callerVote,
    required this.status,
    this.dueByUtc,
    this.penaltyPercentage,
    this.createdAtUtc,
    this.requesterRole,
    this.requiredDecisionBy,
    this.callerCanDecide = false,
  });

  factory BorrowRequestListItemModel.fromJson(Map<String, dynamic> json) {
    return BorrowRequestListItemModel(
      id: (json['id'] as String?) ?? '',
      memberId: (json['memberId'] as String?) ?? '',
      memberName: (json['memberName'] as String?) ?? '',
      memberUsername: (json['memberUsername'] as String?) ?? '',
      memberPhotoUrl: json['memberPhotoUrl'] as String?,
      reason: (json['reason'] as String?) ?? '',
      requestedAmount: (json['requestedAmount'] as num?)?.toDouble() ?? 0,
      upvoteCount: (json['upvoteCount'] as num?)?.toInt() ?? 0,
      downvoteCount: (json['downvoteCount'] as num?)?.toInt() ?? 0,
      callerVote: json['callerVote'] as String?,
      status: (json['status'] as String?) ?? 'Pending',
      dueByUtc: json['dueByUtc'] as String?,
      penaltyPercentage: (json['penaltyPercentage'] as num?)?.toDouble(),
      createdAtUtc: json['createdAtUtc'] as String?,
      requesterRole: json['requesterRole'] as String?,
      requiredDecisionBy: json['requiredDecisionBy'] as String?,
      callerCanDecide: json['callerCanDecide'] == true,
    );
  }

  BorrowRequestEntity toEntity() {
    return BorrowRequestEntity(
      id: id,
      memberId: memberId,
      initials: UserVffHubMapperInitials.initials(memberName),
      memberName: memberName,
      memberPhotoUrl: memberPhotoUrl,
      loanType: reason,
      requestedAmount: requestedAmount,
      upvotes: upvoteCount,
      downvotes: downvoteCount,
      callerVote: callerVote,
      status: status,
      callerCanDecide: callerCanDecide,
      requesterRole: requesterRole,
      requiredDecisionBy: requiredDecisionBy,
    );
  }
}
