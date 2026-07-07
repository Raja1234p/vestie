import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_presentation.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_variant.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('investment stop contributions rejected — leader Figma copy', () {
    const rejectedTitle =
        AppStrings.successVoteOutcomeInvestmentStopContributionsRejectedTitle;
    const rejectedSubtitle =
        AppStrings.successVoteOutcomeInvestmentStopContributionsRejectedSubtitle;
    const rejectedAmount = AppStrings
        .successVoteOutcomeInvestmentStopContributionsRejectedAmountCaption;
    const rejectedButton = AppStrings.btnBackToHome;

    const rejectedData = SuccessVoteOutcomeUiData(
      isApproved: false,
      amountUsd: 9800,
      agreedCount: 2,
      disagreedCount: 5,
      totalMemberCount: 7,
    );

    test('copy matches Figma', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.groupLeader,
        category: ProjectCategory.investment,
        variant: SuccessVoteOutcomeVariant.stopContributionsRejected,
      );

      expect(copy.titleFor(false), rejectedTitle);
      expect(copy.subtitleFor(false), rejectedSubtitle);
      expect(copy.amountCaptionFor(false), rejectedAmount);
      expect(copy.primaryButtonFor(false), rejectedButton);
    });

    test('presentation uses red caption accent', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.groupLeader,
        category: ProjectCategory.investment,
        variant: SuccessVoteOutcomeVariant.stopContributionsRejected,
      );

      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: rejectedData,
        copy: copy,
        variant: SuccessVoteOutcomeVariant.stopContributionsRejected,
        category: ProjectCategory.investment,
      );

      expect(resolved.title, rejectedTitle);
      expect(resolved.subtitle, rejectedSubtitle);
      expect(resolved.amountCaption, rejectedAmount);
      expect(resolved.buttonText, rejectedButton);
      expect(resolved.rejectedCaptionAccentRed, isTrue);
    });

    test('route args from completed investment project', () {
      final args = successVoteOutcomeRouteArgsFromProject(
        Project(
          id: 'p1',
          name: 'Growth Fund',
          category: ProjectCategory.investment,
          status: ProjectStatus.completed,
          relation: ProjectRelation.owned,
          currentAmount: 9800,
          memberCount: 7,
          viewerRole: ViewerMembershipRole.groupLeader,
          successVoteApproved: false,
          displayStatus: 'On Going',
        ),
      );

      expect(args.variant, SuccessVoteOutcomeVariant.stopContributionsRejected);
      expect(args.viewerRole, SuccessVoteOutcomeRole.groupLeader);

      final copy = SuccessVoteOutcomeCopy.forRole(
        args.viewerRole,
        category: args.resolvedCategory,
        variant: args.variant,
      );
      expect(copy.titleFor(false), rejectedTitle);
    });
  });
}
