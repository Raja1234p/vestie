import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('vacation not approved — all roles share Figma copy', () {
    const rejectedTitle = AppStrings.successVoteOutcomeLeaderRejectedTitle;
    const rejectedSubtitle =
        AppStrings.successVoteOutcomeLeaderRejectedSubtitle;
    const rejectedAmount =
        AppStrings.successVoteOutcomeLeaderAmountRejectedCaption;
    const rejectedButton = AppStrings.btnBackToHome;

    void expectVacationNotApproved(SuccessVoteOutcomeRole role) {
      final copy = SuccessVoteOutcomeCopy.forRole(
        role,
        category: ProjectCategory.vacations,
      );
      expect(copy.titleFor(false), rejectedTitle);
      expect(copy.subtitleFor(false), rejectedSubtitle);
      expect(copy.amountCaptionFor(false), rejectedAmount);
      expect(copy.primaryButtonFor(false), rejectedButton);
    }

    test('group leader', () => expectVacationNotApproved(
          SuccessVoteOutcomeRole.groupLeader,
        ));

    test('co-leader', () => expectVacationNotApproved(
          SuccessVoteOutcomeRole.coLeader,
        ));

    test('member', () => expectVacationNotApproved(
          SuccessVoteOutcomeRole.member,
        ));
  });
}
