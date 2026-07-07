import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_presentation.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('emergency not approved — all roles share Figma copy', () {
    const rejectedTitle =
        AppStrings.successVoteOutcomeEmergencyLeaderRejectedTitle;
    const rejectedSubtitle =
        AppStrings.successVoteOutcomeEmergencyLeaderRejectedSubtitle;
    const rejectedAmount =
        AppStrings.successVoteOutcomeEmergencyLeaderAmountRejectedCaption;
    const rejectedButton = AppStrings.btnBackToHome;

    const rejectedData = SuccessVoteOutcomeUiData(
      isApproved: false,
      amountUsd: 9800,
      agreedCount: 2,
      disagreedCount: 5,
      totalMemberCount: 7,
    );

    void expectEmergencyNotApproved(SuccessVoteOutcomeRole role) {
      final copy = SuccessVoteOutcomeCopy.forRole(
        role,
        category: ProjectCategory.emergency,
      );
      expect(copy.titleFor(false), rejectedTitle);
      expect(copy.subtitleFor(false), rejectedSubtitle);
      expect(copy.amountCaptionFor(false), rejectedAmount);
      expect(copy.primaryButtonFor(false), rejectedButton);

      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: rejectedData,
        copy: copy,
        category: ProjectCategory.emergency,
      );
      expect(resolved.title, rejectedTitle);
      expect(resolved.subtitle, rejectedSubtitle);
      expect(resolved.amountCaption, rejectedAmount);
      expect(resolved.buttonText, rejectedButton);
      expect(resolved.rejectedCaptionAccentRed, isTrue);
    }

    test('group leader', () => expectEmergencyNotApproved(
          SuccessVoteOutcomeRole.groupLeader,
        ));

    test('co-leader', () => expectEmergencyNotApproved(
          SuccessVoteOutcomeRole.coLeader,
        ));

    test('member', () => expectEmergencyNotApproved(
          SuccessVoteOutcomeRole.member,
        ));
  });

  group('vacation not approved caption accent', () {
    test('uses gray caption (not red accent)', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.member,
        category: ProjectCategory.vacations,
      );
      const data = SuccessVoteOutcomeUiData(
        isApproved: false,
        amountUsd: 9800,
        agreedCount: 2,
        disagreedCount: 5,
        totalMemberCount: 7,
      );

      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: data,
        copy: copy,
        category: ProjectCategory.vacations,
      );

      expect(resolved.rejectedCaptionAccentRed, isFalse);
    });
  });
}
