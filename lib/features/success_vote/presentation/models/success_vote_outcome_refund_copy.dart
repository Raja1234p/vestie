import 'package:vestie/core/constants/app_strings.dart';

import 'success_vote_outcome_refund_phase.dart';

/// Shared refund-state strings — same for leader, co-leader, and member (Figma).
class SuccessVoteOutcomeRefundCopy {
  final String title;
  final String subtitle;
  final String amountCaption;

  const SuccessVoteOutcomeRefundCopy({
    required this.title,
    required this.subtitle,
    required this.amountCaption,
  });

  factory SuccessVoteOutcomeRefundCopy.forPhase(
    SuccessVoteOutcomeRefundPhase phase,
  ) {
    return switch (phase) {
      SuccessVoteOutcomeRefundPhase.inProgress => const SuccessVoteOutcomeRefundCopy(
        title: AppStrings.successVoteOutcomeRefundInProgressTitle,
        subtitle: AppStrings.successVoteOutcomeRefundInProgressSubtitle,
        amountCaption:
            AppStrings.successVoteOutcomeRefundInProgressAmountCaption,
      ),
      SuccessVoteOutcomeRefundPhase.complete => const SuccessVoteOutcomeRefundCopy(
        title: AppStrings.successVoteOutcomeRefundCompleteTitle,
        subtitle: AppStrings.successVoteOutcomeRefundCompleteSubtitle,
        amountCaption: AppStrings.successVoteOutcomeRefundCompleteAmountCaption,
      ),
      SuccessVoteOutcomeRefundPhase.none => const SuccessVoteOutcomeRefundCopy(
        title: '',
        subtitle: '',
        amountCaption: '',
      ),
    };
  }
}
