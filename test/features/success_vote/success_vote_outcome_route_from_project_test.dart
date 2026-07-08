import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_refund_phase.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('successVoteOutcomeRouteArgsFromProject', () {
    Project vacationLeader({bool approved = true}) => Project(
      id: 'p1',
      name: 'Europe Trip',
      category: ProjectCategory.vacations,
      status: ProjectStatus.completed,
      relation: ProjectRelation.owned,
      currentAmount: 9800,
      memberCount: 7,
      viewerRole: ViewerMembershipRole.groupLeader,
      successVoteApproved: approved,
    );

    test('maps group leader viewerRole from list project', () {
      final args = successVoteOutcomeRouteArgsFromProject(vacationLeader());
      expect(args.viewerRole, SuccessVoteOutcomeRole.groupLeader);
      expect(args.data.isApproved, isTrue);
      expect(args.data.amountUsd, 9800);
      expect(args.data.totalMemberCount, 7);
    });

    test('leader vacation approved copy matches Figma', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.groupLeader,
        category: ProjectCategory.vacations,
      );
      expect(copy.titleFor(true), AppStrings.successVoteOutcomeLeaderApprovedTitle);
      expect(
        copy.amountCaptionFor(true),
        AppStrings.successVoteOutcomeVacationLeaderAmountApprovedCaption,
      );
    });

    test('leader emergency approved copy matches Figma', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.groupLeader,
        category: ProjectCategory.emergency,
      );
      expect(copy.titleFor(true), AppStrings.successVoteOutcomeLeaderApprovedTitle);
      expect(
        copy.subtitleFor(true),
        AppStrings.successVoteOutcomeLeaderApprovedSubtitle,
      );
      expect(
        copy.amountCaptionFor(true),
        AppStrings.successVoteOutcomeEmergencyLeaderAmountApprovedCaption,
      );
      expect(copy.primaryButtonFor(true), AppStrings.btnBackToHome);
    });

    test('co-leader emergency approved copy matches Figma', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.coLeader,
        category: ProjectCategory.emergency,
      );
      expect(
        copy.titleFor(true),
        AppStrings.successVoteOutcomeEmergencyCoLeaderMemberApprovedTitle,
      );
      expect(
        copy.subtitleFor(true),
        AppStrings.successVoteOutcomeEmergencyCoLeaderMemberApprovedSubtitle,
      );
      expect(
        copy.amountCaptionFor(true),
        AppStrings.successVoteOutcomeEmergencyCoLeaderMemberAmountApprovedCaption,
      );
      expect(copy.primaryButtonFor(true), AppStrings.btnBackToHome);
    });

    test('member emergency approved copy matches Figma', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.member,
        category: ProjectCategory.emergency,
      );
      expect(
        copy.titleFor(true),
        AppStrings.successVoteOutcomeEmergencyCoLeaderMemberApprovedTitle,
      );
      expect(
        copy.subtitleFor(true),
        AppStrings.successVoteOutcomeEmergencyCoLeaderMemberApprovedSubtitle,
      );
      expect(
        copy.amountCaptionFor(true),
        AppStrings.successVoteOutcomeEmergencyCoLeaderMemberAmountApprovedCaption,
      );
      expect(copy.primaryButtonFor(true), AppStrings.btnBackToHome);
    });

    test('member vacation approved copy matches Figma', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.member,
        category: ProjectCategory.vacations,
      );
      expect(copy.titleFor(true), AppStrings.successVoteOutcomeCoLeaderApprovedTitle);
      expect(
        copy.subtitleFor(true),
        AppStrings.successVoteOutcomeCoLeaderApprovedSubtitle,
      );
      expect(
        copy.amountCaptionFor(true),
        AppStrings.successVoteOutcomeCoLeaderAmountApprovedCaption,
      );
      expect(copy.primaryButtonFor(true), AppStrings.btnBackToHome);
    });

    test('co-leader vacation approved copy matches Figma', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.coLeader,
        category: ProjectCategory.vacations,
      );
      expect(copy.titleFor(true), AppStrings.successVoteOutcomeCoLeaderApprovedTitle);
      expect(
        copy.subtitleFor(true),
        AppStrings.successVoteOutcomeCoLeaderApprovedSubtitle,
      );
      expect(
        copy.amountCaptionFor(true),
        AppStrings.successVoteOutcomeCoLeaderAmountApprovedCaption,
      );
      expect(copy.primaryButtonFor(true), AppStrings.btnBackToHome);
    });

    test('maps refund phase from displayStatus', () {
      final args = successVoteOutcomeRouteArgsFromProject(
        Project(
          id: 'p1',
          name: 'Fund',
          category: ProjectCategory.investment,
          status: ProjectStatus.completed,
          relation: ProjectRelation.joined,
          currentAmount: 9800,
          displayStatus: 'Refund complete',
          lastVoteType: 'StopContributionsVote',
          lastVoteOutcome: 'Refund',
        ),
      );
      expect(args.data.isApproved, isFalse);
      expect(args.refundPhase, SuccessVoteOutcomeRefundPhase.complete);
    });
  });

  group('Project.showsHomeActionButton completed', () {
    test('shows View for completed owned projects', () {
      final project = Project(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.completed,
        relation: ProjectRelation.owned,
      );
      expect(project.showsHomeActionButton, isTrue);
    });
    test('treats refund display status as not approved', () {
      final project = Project(
        id: 'p1',
        name: 'Fund',
        category: ProjectCategory.investment,
        status: ProjectStatus.completed,
        relation: ProjectRelation.joined,
        displayStatus: 'Refund in progress',
      );
      expect(project.isSuccessVoteApproved, isFalse);
    });
  });
}
