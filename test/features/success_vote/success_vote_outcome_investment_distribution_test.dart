import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_distribution_phase.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_presentation.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
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

  group('investment final closure approved — unified Figma copy (all roles)', () {
    const approvedData = SuccessVoteOutcomeUiData(
      isApproved: true,
      amountUsd: 19800,
      agreedCount: 5,
      disagreedCount: 2,
      totalMemberCount: 7,
    );

    void expectFinalApprovedCopy(SuccessVoteOutcomeRole role) {
      final copy = SuccessVoteOutcomeCopy.forRole(
        role,
        category: ProjectCategory.investment,
      );
      expect(
        copy.titleFor(true),
        AppStrings.successVoteOutcomeInvestmentFinalApprovedTitle,
      );
      expect(
        copy.subtitleFor(true),
        AppStrings.successVoteOutcomeInvestmentFinalApprovedSubtitle,
      );
      expect(
        copy.amountCaptionFor(true),
        AppStrings.successVoteOutcomeInvestmentFinalApprovedAmountCaption,
      );

      for (final phase in [
        SuccessVoteOutcomeDistributionPhase.none,
        SuccessVoteOutcomeDistributionPhase.inProgress,
        SuccessVoteOutcomeDistributionPhase.complete,
      ]) {
        final resolved = SuccessVoteOutcomePresentation.resolve(
          data: approvedData,
          copy: copy,
          category: ProjectCategory.investment,
        );
        expect(resolved.title, 'Project Successfully completed!');
        expect(resolved.subtitle, 'Majority of members agreed.');
        expect(
          resolved.amountCaption,
          'Total Funds distributed to all the contributors',
        );
        expect(resolved.buttonText, AppStrings.btnBackToHome);
      }
    }

    test('group leader', () =>
        expectFinalApprovedCopy(SuccessVoteOutcomeRole.groupLeader));

    test('co-leader', () =>
        expectFinalApprovedCopy(SuccessVoteOutcomeRole.coLeader));

    test('member', () => expectFinalApprovedCopy(SuccessVoteOutcomeRole.member));
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
