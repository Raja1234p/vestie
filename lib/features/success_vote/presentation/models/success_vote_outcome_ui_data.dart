import 'package:intl/intl.dart';

import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Shared display model for approved / rejected success-vote outcome screens.
class SuccessVoteOutcomeUiData {
  final bool isApproved;
  final double amountUsd;
  final int agreedCount;
  final int disagreedCount;
  final int totalMemberCount;

  const SuccessVoteOutcomeUiData({
    required this.isApproved,
    required this.amountUsd,
    required this.agreedCount,
    required this.disagreedCount,
    required this.totalMemberCount,
  });

  bool get isRejected => !isApproved;

  int get agreedPercent => totalMemberCount == 0
      ? 0
      : (agreedCount * 100 / totalMemberCount).round();

  int get disagreedPercent => totalMemberCount == 0
      ? 0
      : (disagreedCount * 100 / totalMemberCount).round();

  String get formattedAmountUsd {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amountUsd);
  }

  factory SuccessVoteOutcomeUiData.fromProject(
    Project project, {
    required bool isApproved,
  }) {
    final amount = project.currentAmount ?? 0;
    const defaultMembers = 7;
    final agreed = isApproved ? 5 : 2;
    return SuccessVoteOutcomeUiData(
      isApproved: isApproved,
      amountUsd: amount,
      agreedCount: agreed,
      disagreedCount: defaultMembers - agreed,
      totalMemberCount: defaultMembers,
    );
  }

  factory SuccessVoteOutcomeUiData.preview({
    required bool isApproved,
    ProjectDetailEntity? project,
  }) {
    final raised = project?.currentAmount ?? 9800;
    final members = project?.members.length ?? 7;
    return SuccessVoteOutcomeUiData(
      isApproved: isApproved,
      amountUsd: raised,
      agreedCount: isApproved ? 5 : 2,
      disagreedCount: isApproved ? 2 : 5,
      totalMemberCount: members > 0 ? members : 7,
    );
  }
}

/// @deprecated Use [SuccessVoteOutcomeUiData].
typedef MemberVoteOutcomeUiData = SuccessVoteOutcomeUiData;
