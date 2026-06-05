import 'member_entity.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

enum MemberActivityTransactionKind { contribution, borrow, other }

class MemberActivityTransactionEntity {
  final MemberActivityTransactionKind kind;
  final double amount;
  final String displayDate;
  final String title;

  const MemberActivityTransactionEntity({
    required this.kind,
    required this.amount,
    required this.displayDate,
    required this.title,
  });
}

/// `GET /projects/{projectId}/members/{userId}/activity`
class MemberActivityEntity {
  final MemberEntity member;
  final bool isCoLeader;
  final double totalContributed;
  final int contributionCount;
  final double totalBorrowed;
  final int overdueBorrowCount;
  final double? overdueAmount;
  final double totalReturned;
  final VffConnectionState vffConnectionState;
  final bool canSendVffRequest;
  final String? pendingVffRequestId;
  final List<MemberActivityTransactionEntity> transactions;

  const MemberActivityEntity({
    required this.member,
    this.isCoLeader = false,
    required this.totalContributed,
    required this.contributionCount,
    required this.totalBorrowed,
    this.overdueBorrowCount = 0,
    this.overdueAmount,
    this.totalReturned = 0,
    this.vffConnectionState = VffConnectionState.none,
    this.canSendVffRequest = false,
    this.pendingVffRequestId,
    required this.transactions,
  });

  bool get hasOverdue =>
      overdueBorrowCount > 0 ||
      (overdueAmount != null && overdueAmount! > 0);

  MemberActivityEntity copyWith({
    MemberEntity? member,
    VffConnectionState? vffConnectionState,
    bool? canSendVffRequest,
    String? pendingVffRequestId,
    bool clearPendingVffRequestId = false,
  }) {
    return MemberActivityEntity(
      member: member ?? this.member,
      isCoLeader: isCoLeader,
      totalContributed: totalContributed,
      contributionCount: contributionCount,
      totalBorrowed: totalBorrowed,
      overdueBorrowCount: overdueBorrowCount,
      overdueAmount: overdueAmount,
      totalReturned: totalReturned,
      vffConnectionState: vffConnectionState ?? this.vffConnectionState,
      canSendVffRequest: canSendVffRequest ?? this.canSendVffRequest,
      pendingVffRequestId: clearPendingVffRequestId
          ? null
          : (pendingVffRequestId ?? this.pendingVffRequestId),
      transactions: transactions,
    );
  }
}
