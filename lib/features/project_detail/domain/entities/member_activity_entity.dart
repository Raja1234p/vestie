import 'member_entity.dart';

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
  final double totalContributed;
  final int contributionCount;
  final double totalBorrowed;
  final int overdueBorrowCount;
  final double? overdueAmount;
  final List<MemberActivityTransactionEntity> transactions;

  const MemberActivityEntity({
    required this.member,
    required this.totalContributed,
    required this.contributionCount,
    required this.totalBorrowed,
    this.overdueBorrowCount = 0,
    this.overdueAmount,
    required this.transactions,
  });

  bool get hasOverdue =>
      overdueBorrowCount > 0 ||
      (overdueAmount != null && overdueAmount! > 0);
}
