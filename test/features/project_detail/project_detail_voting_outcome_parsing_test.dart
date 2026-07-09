import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/data/models/project_detail_response_model.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_completed_outcome_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/projects/data/models/project_summary_model.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_refund_phase.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_variant.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('ProjectDetailResponseModel voting outcome fields', () {
    Map<String, dynamic> _detailJson(Map<String, dynamic> voting) {
      return {
        'project': {
          'id': 'p1',
          'name': 'Fund',
          'type': 'investment',
          'displayStatus': 'On Going',
          'targetAmount': 15000,
          'raisedAmount': 9800,
          'viewerRole': 'GroupLeader',
        },
        'rules': {'borrowingAllowed': false},
        'viewerMembership': {
          'membershipId': 'm1',
          'userId': 'u1',
          'role': 'groupLead',
        },
        'members': {'items': []},
        'invites': {'items': []},
        'announcements': {'items': []},
        'projectStatus': 'ongoing',
        'votingStatus': 'done',
        'userRole': 'leader',
        'canStopContributions': true,
        'voting': voting,
      };
    }

    test('parses stop-contributions rejected envelope', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _detailJson({
          'startedAtUtc': '2026-07-01T12:00:00Z',
          'deadlineAtUtc': '2026-07-03T12:00:00Z',
          'voteType': 'StopContributionsVote',
          'outcome': 'Disputed',
          'isApproved': false,
          'isFinalized': true,
          'agreedCount': 2,
          'disagreedCount': 5,
          'pendingCount': 0,
          'eligibleVoterCount': 7,
          'hasVoted': false,
          'memberVotes': [],
        }),
      ).toEntity();

      expect(entity.voting?.voteType, ClosureVoteType.stopContributionsVote);
      expect(entity.voting?.outcome, ClosureVoteOutcome.disputed);
      expect(entity.voting?.resolvedIsApproved, isFalse);
      expect(entity.isClosureVoteOutcomeApproved, isFalse);
      expect(entity.hasFinalizedClosureVoteOutcome, isTrue);
      expect(entity.showsCompletedProjectVoteOutcome, isTrue);
      expect(
        completedOutcomeVariantFromProjectDetail(entity),
        SuccessVoteOutcomeVariant.stopContributionsRejected,
      );
    });

    test('approved stop-contributions keeps distribute layout, not outcome', () {
      final entity = ProjectDetailResponseModel.fromJson({
        ..._detailJson({
          'startedAtUtc': '2026-07-01T12:00:00Z',
          'deadlineAtUtc': '2026-07-03T12:00:00Z',
          'voteType': 'StopContributionsVote',
          'outcome': 'InvestmentStarted',
          'isApproved': true,
          'isFinalized': true,
          'agreedCount': 5,
          'disagreedCount': 2,
          'pendingCount': 0,
          'eligibleVoterCount': 7,
          'hasVoted': false,
          'memberVotes': [],
        }),
        'canStopContributions': false,
        'project': {
          'id': 'p1',
          'name': 'Fund',
          'type': 'investment',
          'displayStatus': 'Funded',
          'targetAmount': 15000,
          'raisedAmount': 9800,
          'viewerRole': 'GroupLeader',
          'lifecycleState': 'funded',
        },
      }).toEntity();

      expect(entity.voting?.voteType, ClosureVoteType.stopContributionsVote);
      expect(entity.voting?.resolvedIsApproved, isTrue);
      expect(entity.hasFinalizedClosureVoteOutcome, isTrue);
      expect(entity.showsInvestmentDistributionActions, isTrue);
      expect(entity.showsCompletedProjectVoteOutcome, isFalse);
    });

    test('parses stop-contributions refund outcome', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _detailJson({
          'startedAtUtc': '2026-07-01T12:00:00Z',
          'deadlineAtUtc': '2026-07-03T12:00:00Z',
          'voteType': 'StopContributionsVote',
          'outcome': 'Refund',
          'isApproved': false,
          'isFinalized': true,
          'agreedCount': 2,
          'disagreedCount': 5,
          'pendingCount': 0,
          'hasVoted': true,
          'memberVotes': [],
        }),
      ).toEntity();

      expect(entity.showsClosureVoteRefundOutcome, isTrue);
      expect(
        refundPhaseFromProjectDetail(entity),
        isNot(SuccessVoteOutcomeRefundPhase.none),
      );
      expect(
        completedOutcomeVariantFromProjectDetail(entity),
        SuccessVoteOutcomeVariant.successVote,
      );
    });

    test('investment final closure approved outcome amount uses totalContributed',
        () {
      final entity = ProjectDetailResponseModel.fromJson({
        ..._detailJson({
          'startedAtUtc': '2026-07-01T12:00:00Z',
          'deadlineAtUtc': '2026-07-03T12:00:00Z',
          'voteType': 'FinalClosureVote',
          'outcome': 'Success',
          'isApproved': true,
          'isFinalized': true,
          'agreedCount': 5,
          'disagreedCount': 2,
          'pendingCount': 0,
          'eligibleVoterCount': 7,
          'hasVoted': true,
          'memberVotes': [],
        }),
        'projectStatus': 'completed',
        'project': {
          'id': 'p1',
          'name': 'Fund',
          'type': 'investment',
          'displayStatus': 'Completed',
          'targetAmount': 15000,
          'totalContributed': 500,
          'raisedAmount': 0,
          'potAmount': 0,
          'viewerRole': 'Member',
          'lifecycleState': 'completed',
        },
      }).toEntity();

      expect(entity.isApprovedInvestmentFinalClosureOutcome, isTrue);
      expect(entity.raisedDisplayAmount, 500);
      expect(entity.closureVoteOutcomeAmountUsd, 500);
      expect(
        successVoteOutcomeUiDataFromProjectDetail(entity).amountUsd,
        500,
      );
    });

    test('final closure refund does not use refund lifecycle UI', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _detailJson({
          'startedAtUtc': '2026-07-01T12:00:00Z',
          'deadlineAtUtc': '2026-07-03T12:00:00Z',
          'voteType': 'FinalClosureVote',
          'outcome': 'Refund',
          'isApproved': false,
          'isFinalized': true,
          'agreedCount': 2,
          'disagreedCount': 5,
          'pendingCount': 0,
          'hasVoted': true,
          'memberVotes': [],
        }),
      ).toEntity();

      expect(entity.showsClosureVoteRefundOutcome, isFalse);
      expect(
        refundPhaseFromProjectDetail(entity),
        SuccessVoteOutcomeRefundPhase.none,
      );
    });
  });

  group('ProjectSummaryModel list outcome fields', () {
    test('maps successVoteApproved and last vote metadata', () {
      final model = ProjectSummaryModel.fromJson({
        'id': 'p1',
        'name': 'Fund',
        'description': '',
        'type': 'investment',
        'visibility': 'Public',
        'state': 'active',
        'targetAmount': 15000,
        'raisedAmount': 9800,
        'createdUtc': '2026-07-01T12:00:00Z',
        'borrowingEnabled': false,
        'viewerRole': 'GroupLeader',
        'displayStatus': 'On Going',
        'memberCount': 7,
        'successVoteApproved': false,
        'lastVoteType': 'StopContributionsVote',
        'lastVoteOutcome': 'Disputed',
      });

      expect(model.successVoteApproved, isFalse);
      expect(model.lastVoteType, 'StopContributionsVote');
      expect(model.eligibleMemberCount, 7);

      final listProject = Project(
        id: model.id,
        name: model.name,
        category: ProjectCategory.investment,
        status: ProjectStatus.completed,
        relation: ProjectRelation.owned,
        currentAmount: model.raisedAmount,
        memberCount: model.eligibleMemberCount,
        successVoteApproved: model.successVoteApproved,
        lastVoteType: model.lastVoteType,
        lastVoteOutcome: model.lastVoteOutcome,
        displayStatus: model.displayStatus,
      );

      expect(
        completedOutcomeVariantFromProject(listProject),
        SuccessVoteOutcomeVariant.stopContributionsRejected,
      );
    });
  });

  group('legacy displayStatus fallback', () {
    test('still infers rejection without voting envelope', () {
      final project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.completed,
        goalAmount: 5000,
        currentAmount: 4200,
        endsIn: '2026-12-01',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        viewerRole: ViewerMembershipRole.member,
        displayStatusLabel: 'Project Not Approved',
      );

      expect(project.isClosureVoteOutcomeApproved, isFalse);
      expect(project.hasFinalizedClosureVoteOutcome, isFalse);
    });
  });
}
