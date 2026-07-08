import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

import 'success_vote_outcome_copy.dart';
import 'success_vote_outcome_refund_copy.dart';
import 'success_vote_outcome_refund_phase.dart';
import 'success_vote_outcome_ui_data.dart';
import 'success_vote_outcome_variant.dart';

/// Resolved title / subtitle / amount caption / CTA for outcome screens.
class SuccessVoteOutcomePresentation {
  SuccessVoteOutcomePresentation._();

  static SuccessVoteOutcomeResolvedCopy resolve({
    required SuccessVoteOutcomeUiData data,
    required SuccessVoteOutcomeCopy copy,
    SuccessVoteOutcomeRefundPhase refundPhase =
        SuccessVoteOutcomeRefundPhase.none,
    SuccessVoteOutcomeVariant variant = SuccessVoteOutcomeVariant.successVote,
    ProjectCategory? category,
  }) {
    if (!data.isApproved &&
        category == ProjectCategory.investment &&
        refundPhase.isRefund &&
        variant != SuccessVoteOutcomeVariant.stopContributionsRejected) {
      final refund = SuccessVoteOutcomeRefundCopy.forPhase(refundPhase);
      return SuccessVoteOutcomeResolvedCopy(
        title: refund.title,
        subtitle: refund.subtitle,
        amountCaption: refund.amountCaption,
        buttonText: AppStrings.btnBackToHome,
        rejectedCaptionAccentRed: true,
      );
    }

    final stopContributionsRejected =
        !data.isApproved &&
        variant == SuccessVoteOutcomeVariant.stopContributionsRejected;

    final noVotesRejected =
        !data.isApproved &&
        variant == SuccessVoteOutcomeVariant.noVotesRejected;

    return SuccessVoteOutcomeResolvedCopy(
      title: copy.titleFor(data.isApproved),
      subtitle: copy.subtitleFor(data.isApproved),
      amountCaption: copy.amountCaptionFor(data.isApproved),
      buttonText: copy.primaryButtonFor(data.isApproved),
      rejectedCaptionAccentRed: stopContributionsRejected,
      hideVoteSummary: noVotesRejected,
    );
  }
}

class SuccessVoteOutcomeResolvedCopy {
  final String title;
  final String subtitle;
  final String amountCaption;
  final String buttonText;
  final bool rejectedCaptionAccentRed;
  final bool hideVoteSummary;

  const SuccessVoteOutcomeResolvedCopy({
    required this.title,
    required this.subtitle,
    required this.amountCaption,
    required this.buttonText,
    this.rejectedCaptionAccentRed = false,
    this.hideVoteSummary = false,
  });
}
