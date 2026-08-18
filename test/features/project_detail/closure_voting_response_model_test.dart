import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/data/models/closure_voting_response_model.dart'
    hide ClosureVoteApiValues;
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/leader_voting_flow_kind.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('ActiveClosureVoteResponseModel', () {
    test('parses Week 10 active vote payload', () {
      const json = {
        'closureVoteId': 'vote-1',
        'voteType': 'StopContributionsVote',
        'status': 'Open',
        'votingDeadlineUtc': '2026-06-26T12:00:00+00:00',
        'daysRemaining': 3,
        'thumbsUp': 2,
        'thumbsDown': 1,
        'notYetVoted': 1,
        'goalAmount': 10000.0,
        'totalRaised': 7500.0,
        'memberCount': 4,
        'callerVote': 'Yes',
        'callerIsGL': false,
      };

      final entity = ActiveClosureVoteResponseModel.fromJson(json).toEntity();

      expect(entity.closureVoteId, 'vote-1');
      expect(entity.voteType, ClosureVoteType.stopContributionsVote);
      expect(entity.status, ClosureVoteStatus.open);
      expect(entity.daysRemaining, 3);
      expect(entity.thumbsUp, 2);
      expect(entity.thumbsDown, 1);
      expect(entity.notYetVoted, 1);
      expect(entity.goalAmount, 10000.0);
      expect(entity.totalRaised, 7500.0);
      expect(entity.memberCount, 4);
      expect(entity.callerVote, ClosureVoteValue.yes);
      expect(entity.callerIsGroupLeader, isFalse);
      expect(entity.isOpen, isTrue);
      expect(entity.callerHasAgreed, isTrue);
    });
  });

  group('OpenClosureVoteResponseModel', () {
    test('parses open vote response', () {
      const json = {
        'closureVoteId': 'vote-2',
        'voteType': 'FinalClosureVote',
        'votingDeadlineUtc': '2026-06-26T12:00:00+00:00',
        'votingWindowDays': 5,
        'status': 'Open',
        'thumbsUp': 0,
        'thumbsDown': 0,
        'notYetVoted': 4,
      };

      final entity = OpenClosureVoteResponseModel.fromJson(json).toEntity();

      expect(entity.voteType, ClosureVoteType.finalClosureVote);
      expect(entity.votingWindowDays, 5);
      expect(entity.notYetVoted, 4);
    });
  });

  group('CastClosureVoteResponseModel', () {
    test('parses cast vote response with No', () {
      const json = {
        'closureVoteId': 'vote-3',
        'callerVote': 'No',
        'thumbsUp': 1,
        'thumbsDown': 2,
        'notYetVoted': 0,
      };

      final entity = CastClosureVoteResponseModel.fromJson(json).toEntity();

      expect(entity.callerVote, ClosureVoteValue.no);
      expect(entity.thumbsDown, 2);
    });
  });

  group('FinalizeClosureVoteResponseModel', () {
    test('parses finalize outcome', () {
      const json = {
        'closureVoteId': 'vote-4',
        'voteType': 'SuccessVote',
        'outcome': 'Success',
        'thumbsUp': 3,
        'thumbsDown': 2,
        'notYetVoted': 0,
        'projectStatus': 'Completed',
      };

      final entity = FinalizeClosureVoteResponseModel.fromJson(json).toEntity();

      expect(entity.outcome, ClosureVoteOutcome.success);
      expect(entity.projectStatus, 'Completed');
    });
  });

  group('CancelClosureVoteResponseModel', () {
    test('parses deployed cancel 200 payload', () {
      const json = {
        'cancelled': true,
        'projectId': '25f7fe65-5fd8-4b00-991c-2c45f16001d5',
        'votingStatus': 'not_started',
      };

      final entity = CancelClosureVoteResponseModel.fromJson(json).toEntity();

      expect(entity.cancelled, isTrue);
      expect(entity.projectId, '25f7fe65-5fd8-4b00-991c-2c45f16001d5');
      expect(entity.votingStatusRaw, 'not_started');
      expect(entity.restoredToNotStarted, isTrue);
    });

    test('treats cancelled false as not restored', () {
      const json = {
        'cancelled': false,
        'projectId': 'p1',
        'votingStatus': 'pending',
      };

      final entity = CancelClosureVoteResponseModel.fromJson(json).toEntity();

      expect(entity.cancelled, isFalse);
      expect(entity.restoredToNotStarted, isFalse);
    });
  });

  group('closureVoteTypeToApiValue', () {
    test('maps entity vote types to API strings', () {
      expect(
        closureVoteTypeToApiValue(ClosureVoteType.successVote),
        ClosureVoteApiValues.voteTypeSuccess,
      );
      expect(
        closureVoteTypeToApiValue(ClosureVoteType.stopContributionsVote),
        ClosureVoteApiValues.voteTypeStopContributions,
      );
      expect(
        closureVoteTypeToApiValue(ClosureVoteType.finalClosureVote),
        ClosureVoteApiValues.voteTypeFinalClosure,
      );
    });
  });

  group('resolveClosureVoteType', () {
    test('maps leader flows and categories', () {
      expect(
        resolveClosureVoteType(
          flowKind: LeaderVotingFlowKind.stopContributions,
          category: ProjectCategory.investment,
        ),
        ClosureVoteType.stopContributionsVote,
      );
      expect(
        resolveClosureVoteType(
          flowKind: LeaderVotingFlowKind.markProjectSuccessful,
          category: ProjectCategory.vacations,
        ),
        ClosureVoteType.successVote,
      );
      expect(
        resolveClosureVoteType(
          flowKind: LeaderVotingFlowKind.markProjectSuccessful,
          category: ProjectCategory.investment,
        ),
        ClosureVoteType.finalClosureVote,
      );
    });
  });
}
