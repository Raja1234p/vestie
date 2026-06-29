import 'package:equatable/equatable.dart';

/// Penalty breakdown from `GET …/members/{userId}/activity` → `penalty`.
class MemberActivityPenaltyBreakdownEntity extends Equatable {
  final double dueAmount;
  final DateTime? overdueDateUtc;
  final double penaltyAmount;
  final double totalOwed;

  const MemberActivityPenaltyBreakdownEntity({
    required this.dueAmount,
    this.overdueDateUtc,
    required this.penaltyAmount,
    required this.totalOwed,
  });

  @override
  List<Object?> get props => [
    dueAmount,
    overdueDateUtc,
    penaltyAmount,
    totalOwed,
  ];
}

class MemberActivityPenaltyEntity extends Equatable {
  final double borrowedAmount;
  final MemberActivityPenaltyBreakdownEntity breakdown;
  final String currency;
  final String? borrowRequestId;
  final bool canMarkAsDefaulted;
  final bool canRemoveMember;

  const MemberActivityPenaltyEntity({
    required this.borrowedAmount,
    required this.breakdown,
    this.currency = 'USD',
    this.borrowRequestId,
    this.canMarkAsDefaulted = false,
    this.canRemoveMember = false,
  });

  @override
  List<Object?> get props => [
    borrowedAmount,
    breakdown,
    currency,
    borrowRequestId,
    canMarkAsDefaulted,
    canRemoveMember,
  ];
}
