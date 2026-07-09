import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_variant.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  test('penalty member vacation approved mirrors leader payout copy', () {
    final copy = SuccessVoteOutcomeCopy.forRole(
      SuccessVoteOutcomeRole.member,
      category: ProjectCategory.vacations,
      viewerPenaltyIneligible: true,
    );
    expect(copy.titleFor(true), AppStrings.successVoteOutcomeCoLeaderApprovedTitle);
    expect(
      copy.amountCaptionFor(true),
      AppStrings.successVoteOutcomePenaltyVacationApprovedAmountCaption,
    );
    expect(copy.amountCaptionFor(true), contains('project leader'));
    expect(copy.amountCaptionFor(true), isNot(contains('eligible to receive')));
  });

  test('penalty member emergency approved mirrors leader payout copy', () {
    final copy = SuccessVoteOutcomeCopy.forRole(
      SuccessVoteOutcomeRole.member,
      category: ProjectCategory.emergency,
      viewerPenaltyIneligible: true,
    );
    expect(
      copy.titleFor(true),
      AppStrings.successVoteOutcomeEmergencyCoLeaderMemberApprovedTitle,
    );
    expect(
      copy.amountCaptionFor(true),
      AppStrings.successVoteOutcomePenaltyEmergencyApprovedAmountCaption,
    );
    expect(copy.amountCaptionFor(true), contains('released to leader'));
  });

  test('penalty member rejected outcome avoids wallet refund copy', () {
    final copy = SuccessVoteOutcomeCopy.forRole(
      SuccessVoteOutcomeRole.member,
      category: ProjectCategory.vacations,
      viewerPenaltyIneligible: true,
    );
    expect(copy.subtitleFor(false), AppStrings.successVoteOutcomePenaltyRejectedSubtitle);
    expect(
      copy.amountCaptionFor(false),
      AppStrings.successVoteOutcomePenaltyRejectedAmountCaption,
    );
    expect(
      copy.amountCaptionFor(false),
      isNot(contains('wallet')),
    );
  });

  test('penalty member approved investment uses distribution wording', () {
    final copy = SuccessVoteOutcomeCopy.forRole(
      SuccessVoteOutcomeRole.member,
      category: ProjectCategory.investment,
      viewerPenaltyIneligible: true,
    );
    expect(
      copy.amountCaptionFor(true),
      AppStrings.successVoteOutcomePenaltyInvestmentApprovedAmountCaption,
    );
    expect(copy.amountCaptionFor(true), isNot(contains('eligible to receive')));
  });

  test('penalty member no-votes variant', () {
    final copy = SuccessVoteOutcomeCopy.forRole(
      SuccessVoteOutcomeRole.member,
      category: ProjectCategory.vacations,
      variant: SuccessVoteOutcomeVariant.noVotesRejected,
      viewerPenaltyIneligible: true,
    );
    expect(copy.titleFor(false), AppStrings.successVoteOutcomeNoVotesTitle);
    expect(
      copy.amountCaptionFor(false),
      AppStrings.successVoteOutcomePenaltyNoVotesAmountCaption,
    );
  });

  test('group leader ignores penalty flag', () {
    final copy = SuccessVoteOutcomeCopy.forRole(
      SuccessVoteOutcomeRole.groupLeader,
      category: ProjectCategory.vacations,
      viewerPenaltyIneligible: true,
    );
    expect(
      copy.amountCaptionFor(false),
      AppStrings.successVoteOutcomeLeaderAmountRejectedCaption,
    );
  });
}
