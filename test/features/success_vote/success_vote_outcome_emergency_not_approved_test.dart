import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_presentation.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  const rejectedData = SuccessVoteOutcomeUiData(
    isApproved: false,
    amountUsd: 9800,
    agreedCount: 2,
    disagreedCount: 5,
    totalMemberCount: 7,
  );

  group('emergency not approved — same copy as vacation by role', () {
    test('group leader — contributions being refunded', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.groupLeader,
        category: ProjectCategory.emergency,
      );
      expect(
        copy.titleFor(false),
        AppStrings.successVoteOutcomeLeaderRejectedTitle,
      );
      expect(
        copy.subtitleFor(false),
        AppStrings.successVoteOutcomeLeaderRejectedSubtitle,
      );
      expect(
        copy.amountCaptionFor(false),
        AppStrings.successVoteOutcomeLeaderAmountRejectedCaption,
      );
      expect(copy.primaryButtonFor(false), AppStrings.btnBackToHome);

      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: rejectedData,
        copy: copy,
        category: ProjectCategory.emergency,
      );
      expect(resolved.title, 'Project Not Approved');
      expect(resolved.subtitle, 'Majority of members disagreed.');
      expect(resolved.amountCaption, 'Contributions being refunded');
      expect(resolved.rejectedCaptionAccentRed, isFalse);
    });

    test('co-leader and member — wallet refund caption', () {
      for (final role in [
        SuccessVoteOutcomeRole.coLeader,
        SuccessVoteOutcomeRole.member,
      ]) {
        final copy = SuccessVoteOutcomeCopy.forRole(
          role,
          category: ProjectCategory.emergency,
        );
        expect(copy.titleFor(false), 'Project Not Approved');
        expect(copy.subtitleFor(false), 'Majority of members disagreed.');
        expect(
          copy.amountCaptionFor(false),
          'Your contributions are being refunded to your wallet',
        );
        expect(copy.primaryButtonFor(false), AppStrings.btnBackToHome);

        final resolved = SuccessVoteOutcomePresentation.resolve(
          data: rejectedData,
          copy: copy,
          category: ProjectCategory.emergency,
        );
        expect(resolved.title, 'Project Not Approved');
        expect(resolved.subtitle, 'Majority of members disagreed.');
        expect(
          resolved.amountCaption,
          'Your contributions are being refunded to your wallet',
        );
        expect(resolved.buttonText, AppStrings.btnBackToHome);
        expect(resolved.rejectedCaptionAccentRed, isFalse);
      }
    });
  });
}
