import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_copy.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  test('investment stop-contributions cast copy matches Figma', () {
    final copy = SuccessVoteCastCopy.forViewer(
      category: ProjectCategory.investment,
      isCoLeader: false,
      isInvestmentStopContributionsVote: true,
    );

    expect(
      copy.pendingBannerTitle,
      AppStrings.successVoteCastInvestmentPendingBannerTitle,
    );
    expect(
      copy.pendingBannerBody,
      AppStrings.successVoteCastInvestmentPendingBannerBody,
    );
    expect(copy.voteQuestion, AppStrings.successVoteCastInvestmentVoteQuestion);
    expect(copy.voteYesLabel, 'Yes, Start Investing');
    expect(copy.voteNoLabel, 'No, Refund Me');
  });

  test('investment mark-successful cast copy matches Figma phase 2', () {
    final copy = SuccessVoteCastCopy.forViewer(
      category: ProjectCategory.investment,
      isCoLeader: false,
      isInvestmentMarkSuccessfulVote: true,
    );

    expect(
      copy.pendingBannerTitle,
      AppStrings.successVoteCastInvestmentMarkSuccessfulPendingBannerTitle,
    );
    expect(
      copy.pendingBannerBody,
      AppStrings.successVoteCastInvestmentMarkSuccessfulPendingBannerBody,
    );
    expect(
      copy.voteQuestion,
      AppStrings.successVoteCastInvestmentMarkSuccessfulVoteQuestion,
    );
    expect(copy.voteYesLabel, 'Yes, Confirm Received');
    expect(copy.voteNoLabel, 'No, Dispute');
    expect(copy.statGoalLabel, AppStrings.successVoteCastInvestmentTotalInvested);
    expect(
      copy.totalRaisedLabel,
      AppStrings.successVoteCastInvestmentTotalDistributedInclRoi,
    );
  });

  test('investment mark-successful post-vote agreed copy matches Figma', () {
    final copy = SuccessVoteCastCopy.forViewer(
      category: ProjectCategory.investment,
      isCoLeader: false,
      isInvestmentMarkSuccessfulVote: true,
    );

    expect(
      copy.agreedTitle,
      AppStrings.successVoteCastInvestmentMarkSuccessfulAgreedTitle,
    );
    expect(
      copy.agreedBody,
      AppStrings.successVoteCastInvestmentMarkSuccessfulAgreedBody,
    );
  });

  test('investment mark-successful post-vote disputed copy matches Figma', () {
    final copy = SuccessVoteCastCopy.forViewer(
      category: ProjectCategory.investment,
      isCoLeader: false,
      isInvestmentMarkSuccessfulVote: true,
    );

    expect(
      copy.disagreedTitle,
      AppStrings.successVoteCastInvestmentMarkSuccessfulDisagreedTitle,
    );
    expect(
      copy.disagreedBody,
      AppStrings.successVoteCastInvestmentMarkSuccessfulDisagreedBody,
    );
  });
}
