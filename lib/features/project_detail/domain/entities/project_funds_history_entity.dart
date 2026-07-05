import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/pagination_info.dart';

/// One ledger row from `GET /projects/{projectId}/funds-history`.
class ProjectFundsHistoryEntryEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final double amount;
  final String direction;
  final DateTime? date;

  const ProjectFundsHistoryEntryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.direction,
    this.date,
  });

  bool get isCredit => direction == 'Credit';

  /// Signed amount for ledger UI — Credit positive, Debit negative.
  double get signedAmount => isCredit ? amount : -amount;

  @override
  List<Object?> get props => [id, name, type, amount, direction, date];
}

/// `GET /projects/{projectId}/funds-history` response.
class ProjectFundsHistoryEntity extends Equatable {
  final String projectId;
  final String currency;
  final double currentPotBalance;
  final double totalContribution;
  final double activeBorrows;
  final List<ProjectFundsHistoryEntryEntity> entries;
  final PaginationInfo pagination;

  const ProjectFundsHistoryEntity({
    required this.projectId,
    required this.currency,
    required this.currentPotBalance,
    required this.totalContribution,
    required this.activeBorrows,
    required this.entries,
    required this.pagination,
  });

  @override
  List<Object?> get props => [
    projectId,
    currency,
    currentPotBalance,
    totalContribution,
    activeBorrows,
    entries,
    pagination,
  ];
}
