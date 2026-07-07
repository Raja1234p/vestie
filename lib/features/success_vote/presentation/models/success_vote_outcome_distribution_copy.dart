import 'package:vestie/core/constants/app_strings.dart';

import 'success_vote_outcome_distribution_phase.dart';

/// Investment — approved final closure distribution states (Figma; all roles).
class SuccessVoteOutcomeDistributionCopy {
  final String title;
  final String subtitle;
  final String amountCaption;

  const SuccessVoteOutcomeDistributionCopy({
    required this.title,
    required this.subtitle,
    required this.amountCaption,
  });

  factory SuccessVoteOutcomeDistributionCopy.forPhase(
    SuccessVoteOutcomeDistributionPhase phase,
  ) {
    const subtitle =
        AppStrings.successVoteOutcomeInvestmentLeaderApprovedSubtitle;
    return switch (phase) {
      SuccessVoteOutcomeDistributionPhase.inProgress =>
        const SuccessVoteOutcomeDistributionCopy(
          title: AppStrings.successVoteOutcomeInvestmentDistributionInProgressTitle,
          subtitle: subtitle,
          amountCaption: AppStrings
              .successVoteOutcomeInvestmentDistributionInProgressAmountCaption,
        ),
      SuccessVoteOutcomeDistributionPhase.complete =>
        const SuccessVoteOutcomeDistributionCopy(
          title: AppStrings.successVoteOutcomeInvestmentDistributionCompleteTitle,
          subtitle: subtitle,
          amountCaption: AppStrings
              .successVoteOutcomeInvestmentDistributionCompleteAmountCaption,
        ),
      SuccessVoteOutcomeDistributionPhase.none =>
        const SuccessVoteOutcomeDistributionCopy(
          title: '',
          subtitle: '',
          amountCaption: '',
        ),
    };
  }
}
