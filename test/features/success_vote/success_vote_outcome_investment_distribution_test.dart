import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_distribution_phase.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_presentation.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_variant.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('distributionPhaseFromStatusLabel', () {
    test('maps distributions in progress', () {
      expect(
        distributionPhaseFromStatusLabel('Distributions In Progress'),
        SuccessVoteOutcomeDistributionPhase.inProgress,
      );
    });

    test('maps distribution complete', () {
      expect(
        distributionPhaseFromStatusLabel('Distribution Complete'),
        SuccessVoteOutcomeDistributionPhase.complete,
      );
    });

    test('returns none without distribution keyword', () {
      expect(
        distributionPhaseFromStatusLabel('Completed'),
        SuccessVoteOutcomeDistributionPhase.none,
      );
    });
  });

  group('distributionPhaseFromApiValue', () {
    test('maps InProgress enum', () {
      expect(
        distributionPhaseFromApiValue('InProgress'),
        SuccessVoteOutcomeDistributionPhase.inProgress,
      );
    });

    test('maps Complete enum', () {
      expect(
        distributionPhaseFromApiValue('Complete'),
        SuccessVoteOutcomeDistributionPhase.complete,
      );
    });
  });

  group('SuccessVoteOutcomePresentation investment leader distribution', () {
    const approvedData = SuccessVoteOutcomeUiData(
      isApproved: true,
      amountUsd: 9800,
      agreedCount: 5,
      disagreedCount: 2,
      totalMemberCount: 7,
    );

    final leaderCopy = SuccessVoteOutcomeCopy.forRole(
      SuccessVoteOutcomeRole.groupLeader,
      category: ProjectCategory.investment,
    );

    test('in progress uses Figma leader copy', () {
      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: approvedData,
        copy: leaderCopy,
        distributionPhase: SuccessVoteOutcomeDistributionPhase.inProgress,
        category: ProjectCategory.investment,
      );

      expect(
        resolved.title,
        AppStrings.successVoteOutcomeInvestmentDistributionInProgressTitle,
      );
      expect(
        resolved.subtitle,
        AppStrings.successVoteOutcomeInvestmentLeaderApprovedSubtitle,
      );
      expect(
        resolved.amountCaption,
        AppStrings.successVoteOutcomeInvestmentDistributionInProgressAmountCaption,
      );
      expect(resolved.buttonText, AppStrings.btnBackToHome);
    });

    test('complete uses Figma leader copy', () {
      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: approvedData,
        copy: leaderCopy,
        distributionPhase: SuccessVoteOutcomeDistributionPhase.complete,
        category: ProjectCategory.investment,
      );

      expect(
        resolved.title,
        AppStrings.successVoteOutcomeInvestmentDistributionCompleteTitle,
      );
      expect(
        resolved.amountCaption,
        AppStrings.successVoteOutcomeInvestmentDistributionCompleteAmountCaption,
      );
    });

    test('member uses same Figma distribution copy', () {
      final memberCopy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.member,
        category: ProjectCategory.investment,
      );
      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: approvedData,
        copy: memberCopy,
        distributionPhase: SuccessVoteOutcomeDistributionPhase.inProgress,
        category: ProjectCategory.investment,
      );

      expect(
        resolved.title,
        AppStrings.successVoteOutcomeInvestmentDistributionInProgressTitle,
      );
      expect(
        resolved.subtitle,
        AppStrings.successVoteOutcomeInvestmentLeaderApprovedSubtitle,
      );
      expect(
        resolved.amountCaption,
        AppStrings.successVoteOutcomeInvestmentDistributionInProgressAmountCaption,
      );
    });
  });

  group('distributionPhaseFromProject list', () {
    test('uses distributionStatus from list row', () {
      final project = Project(
        id: 'p1',
        name: 'Fund',
        category: ProjectCategory.investment,
        status: ProjectStatus.completed,
        relation: ProjectRelation.owned,
        successVoteApproved: true,
        lastVoteType: ClosureVoteApiValues.voteTypeFinalClosure,
        lastVoteOutcome: ClosureVoteApiValues.outcomeInvestmentStarted,
        distributionStatus: 'Complete',
        displayStatus: 'Funded',
      );

      expect(
        distributionPhaseFromProject(project),
        SuccessVoteOutcomeDistributionPhase.complete,
      );
    });
  });
}
