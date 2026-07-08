import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_participation_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_completed_outcome_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_presentation.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_variant.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  ProjectVotingSummaryEntity voting({
    required ClosureVoteType voteType,
    ClosureVoteOutcome outcome = ClosureVoteOutcome.noVotes,
    bool isApproved = false,
  }) {
    return ProjectVotingSummaryEntity(
      startedAtUtc: DateTime.utc(2026, 6, 1),
      deadlineAtUtc: DateTime.utc(2026, 6, 3),
      agreedCount: 0,
      disagreedCount: 0,
      pendingCount: 7,
      isFinalized: true,
      voteType: voteType,
      outcome: outcome,
      isApproved: isApproved,
      eligibleVoterCount: 7,
    );
  }

  ProjectDetailEntity detail({
    required ProjectCategory category,
    required ProjectVotingSummaryEntity summary,
    String displayStatus = 'Project Not Approved',
    String lifecycleState = 'completed',
    ProjectStatus status = ProjectStatus.completed,
    ProjectDetailBannerStatus bannerStatus = ProjectDetailBannerStatus.completed,
  }) {
    return ProjectDetailEntity(
      id: 'p1',
      name: 'Trip',
      category: category,
      status: status,
      goalAmount: 5000,
      currentAmount: 9800,
      contributorCount: 7,
      endsIn: 'Jun 1',
      announcement: '',
      members: const [],
      borrowRequests: const [],
      displayStatusLabel: displayStatus,
      projectLifecycleState: lifecycleState,
      projectBannerStatus: bannerStatus,
      votingStatus: ProjectVotingStatus.done,
      voting: summary,
      hasWeek11ProjectDetailEnvelope: true,
      viewerRole: ViewerMembershipRole.member,
    );
  }

  group('no participation detection', () {
    test('agreed and disagreed zero after finalize', () {
      expect(
        isClosureVoteNoParticipation(
          isFinalized: true,
          outcome: ClosureVoteOutcome.disputed,
          agreedCount: 0,
          disagreedCount: 0,
        ),
        isTrue,
      );
    });

    test('explicit NoVotes outcome', () {
      expect(
        isClosureVoteNoParticipation(
          isFinalized: true,
          outcome: ClosureVoteOutcome.noVotes,
          agreedCount: 1,
          disagreedCount: 0,
        ),
        isTrue,
      );
    });
  });

  group('outcome copy — vacation / emergency / investment stop-contrib', () {
    test('leader refund caption', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.groupLeader,
        category: ProjectCategory.vacations,
        variant: SuccessVoteOutcomeVariant.noVotesRejected,
      );
      expect(copy.titleFor(false), AppStrings.successVoteOutcomeNoVotesTitle);
      expect(
        copy.amountCaptionFor(false),
        AppStrings.successVoteOutcomeNoVotesLeaderAmountCaption,
      );
    });

    test('member wallet refund caption', () {
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.member,
        category: ProjectCategory.emergency,
        variant: SuccessVoteOutcomeVariant.noVotesRejected,
      );
      expect(
        copy.amountCaptionFor(false),
        AppStrings.successVoteOutcomeNoVotesMemberAmountCaption,
      );
    });

    test('presentation hides vote summary', () {
      const data = SuccessVoteOutcomeUiData(
        isApproved: false,
        amountUsd: 9800,
        agreedCount: 0,
        disagreedCount: 0,
        totalMemberCount: 7,
      );
      final copy = SuccessVoteOutcomeCopy.forRole(
        SuccessVoteOutcomeRole.member,
        category: ProjectCategory.vacations,
        variant: SuccessVoteOutcomeVariant.noVotesRejected,
      );
      final resolved = SuccessVoteOutcomePresentation.resolve(
        data: data,
        copy: copy,
        variant: SuccessVoteOutcomeVariant.noVotesRejected,
        category: ProjectCategory.vacations,
      );
      expect(resolved.title, 'No One Voted');
      expect(resolved.hideVoteSummary, isTrue);
    });
  });

  group('investment final closure no participation', () {
    test('does not show full-screen outcome — uses distribute UI', () {
      final project = detail(
        category: ProjectCategory.investment,
        summary: voting(
          voteType: ClosureVoteType.finalClosureVote,
          isApproved: true,
          outcome: ClosureVoteOutcome.noVotes,
        ),
        displayStatus: 'Funded',
        lifecycleState: 'funded',
        status: ProjectStatus.ongoing,
        bannerStatus: ProjectDetailBannerStatus.ongoing,
      );
      expect(project.isInvestmentFinalClosureNoParticipation, isTrue);
      expect(project.showsCompletedProjectVoteOutcome, isFalse);
      expect(project.showsInvestmentDistributionActions, isTrue);
    });

    test('variant is not noVotesRejected', () {
      final project = detail(
        category: ProjectCategory.investment,
        summary: voting(
          voteType: ClosureVoteType.finalClosureVote,
          isApproved: true,
          outcome: ClosureVoteOutcome.noVotes,
        ),
        displayStatus: 'Funded',
        lifecycleState: 'funded',
        status: ProjectStatus.ongoing,
        bannerStatus: ProjectDetailBannerStatus.ongoing,
      );
      expect(
        completedOutcomeVariantFromProjectDetail(project),
        SuccessVoteOutcomeVariant.successVote,
      );
    });
  });

  group('investment stop-contrib no participation', () {
    test('shows no-votes outcome variant', () {
      final project = detail(
        category: ProjectCategory.investment,
        summary: voting(voteType: ClosureVoteType.stopContributionsVote),
        displayStatus: 'Project Not Approved',
        lifecycleState: 'ongoing',
      );
      expect(project.showsClosureVoteNoParticipationOutcome, isTrue);
      expect(
        completedOutcomeVariantFromProjectDetail(project),
        SuccessVoteOutcomeVariant.noVotesRejected,
      );
    });
  });
}
