import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_presentation.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_refund_phase.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('refundPhaseFromDisplayStatus', () {
    test('maps refund in progress', () {
      expect(
        refundPhaseFromDisplayStatus('Refund in progress'),
        SuccessVoteOutcomeRefundPhase.inProgress,
      );
    });

    test('maps refund complete', () {
      expect(
        refundPhaseFromDisplayStatus('Refund complete'),
        SuccessVoteOutcomeRefundPhase.complete,
      );
    });

    test('returns none when no refund keyword', () {
      expect(
        refundPhaseFromDisplayStatus('Project Not Approved'),
        SuccessVoteOutcomeRefundPhase.none,
      );
    });
  });

  group('SuccessVoteOutcomePresentation refund copy', () {
    const rejectedData = SuccessVoteOutcomeUiData(
      isApproved: false,
      amountUsd: 9800,
      agreedCount: 2,
      disagreedCount: 5,
      totalMemberCount: 7,
    );

  const genericCopy = SuccessVoteOutcomeCopy(
      approvedTitle: 'Approved',
      approvedSubtitle: 'Approved sub',
      rejectedTitle: 'Project Not Approved',
      rejectedSubtitle: 'Majority disagreed',
      amountCaptionApproved: 'Approved amount',
      amountCaptionRejected: 'Contributions being refunded',
      primaryButtonApproved: 'Back to Home',
      primaryButtonRejected: 'Back to Home',
      voteSummaryLabel: 'Vote Summary',
      agreedLabel: 'Agreed',
      disagreedLabel: 'Disagreed',
    );

    test('in progress uses Figma refund strings', () {
      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: rejectedData,
        copy: genericCopy,
        refundPhase: SuccessVoteOutcomeRefundPhase.inProgress,
        category: ProjectCategory.investment,
      );

      expect(resolved.title, AppStrings.successVoteOutcomeRefundInProgressTitle);
      expect(
        resolved.subtitle,
        AppStrings.successVoteOutcomeRefundInProgressSubtitle,
      );
      expect(
        resolved.amountCaption,
        AppStrings.successVoteOutcomeRefundInProgressAmountCaption,
      );
      expect(resolved.buttonText, AppStrings.btnBackToHome);
      expect(resolved.rejectedCaptionAccentRed, isTrue);
    });

    test('complete uses Figma refund strings', () {
      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: rejectedData,
        copy: genericCopy,
        refundPhase: SuccessVoteOutcomeRefundPhase.complete,
        category: ProjectCategory.investment,
      );

      expect(resolved.title, AppStrings.successVoteOutcomeRefundCompleteTitle);
      expect(
        resolved.subtitle,
        AppStrings.successVoteOutcomeRefundCompleteSubtitle,
      );
      expect(
        resolved.amountCaption,
        AppStrings.successVoteOutcomeRefundCompleteAmountCaption,
      );
      expect(resolved.rejectedCaptionAccentRed, isTrue);
    });

    test('vacation ignores refund phase — uses rejected copy', () {
      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: rejectedData,
        copy: genericCopy,
        refundPhase: SuccessVoteOutcomeRefundPhase.inProgress,
        category: ProjectCategory.vacations,
      );

      expect(resolved.title, 'Project Not Approved');
      expect(resolved.subtitle, 'Majority disagreed');
    });
  });
}
