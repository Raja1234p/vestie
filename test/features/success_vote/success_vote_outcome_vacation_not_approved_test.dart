import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('vacation not approved — Figma copy by role', () {
    test('group leader — contributions being refunded', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.groupLeader,
        category: ProjectCategory.vacations,
      );
      expect(copy.titleFor(false), AppStrings.successVoteOutcomeLeaderRejectedTitle);
      expect(
        copy.subtitleFor(false),
        AppStrings.successVoteOutcomeLeaderRejectedSubtitle,
      );
      expect(
        copy.amountCaptionFor(false),
        AppStrings.successVoteOutcomeLeaderAmountRejectedCaption,
      );
      expect(copy.primaryButtonFor(false), AppStrings.btnBackToHome);
    });

    test('co-leader and member — wallet refund caption', () {
      for (final role in [
        SuccessVoteOutcomeRole.coLeader,
        SuccessVoteOutcomeRole.member,
      ]) {
        final copy = SuccessVoteOutcomeCopy.forRole(
          role,
          category: ProjectCategory.vacations,
        );
        expect(copy.titleFor(false), AppStrings.projectVoteNotApprovedTitle);
        expect(
          copy.amountCaptionFor(false),
          AppStrings.successVoteOutcomeVacationCoLeaderMemberAmountRejectedCaption,
        );
        expect(copy.primaryButtonFor(false), AppStrings.btnBackToHome);
      }
    });
  });
}
