import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/project_detail/data/repositories/closure_voting_failure_mapper.dart';

void main() {
  group('ClosureVotingFailureMapper', () {
    test('maps GL cannot vote forbidden failure', () {
      const failure = ForbiddenFailure('Group Lead cannot vote on this ballot');
      final mapped = ClosureVotingFailureMapper.map(failure);

      expect(mapped, isA<ForbiddenFailure>());
      expect(
        (mapped as ForbiddenFailure).message,
        AppStrings.errorClosureVoteGroupLeaderCannotVote,
      );
    });

    test('maps deadline passed validation failure', () {
      const failure = ValidationFailure('Voting deadline has passed');
      final mapped = ClosureVotingFailureMapper.map(failure);

      expect(mapped, isA<ValidationFailure>());
      expect(
        (mapped as ValidationFailure).message,
        AppStrings.errorClosureVoteDeadlinePassed,
      );
    });

    test('maps no open vote validation failure', () {
      const failure = ValidationFailure('No open vote exists');
      final mapped = ClosureVotingFailureMapper.map(failure);

      expect(mapped, isA<ValidationFailure>());
      expect(
        (mapped as ValidationFailure).message,
        AppStrings.errorClosureVoteNoOpenVote,
      );
    });

    test('keeps generic vote server errors for open/cast (not cancel copy)', () {
      const failure = ServerFailure('Vote was not recorded');
      final mapped = ClosureVotingFailureMapper.map(failure);

      expect(mapped, isA<ServerFailure>());
      expect((mapped as ServerFailure).message, 'Vote was not recorded');
    });

    test('open/cast mapper does not steal majority 50% copy', () {
      const failure = ServerFailure('Need 50% of eligible voters to pass');
      final mapped = ClosureVotingFailureMapper.map(failure);

      expect(mapped, isA<ServerFailure>());
      expect(
        (mapped as ServerFailure).message,
        'Need 50% of eligible voters to pass',
      );
    });

    test('maps cancel 50% threshold from deployed 409 code', () {
      const threshold = ServerFailure(
        'Continue contribution is no longer available because at least 50% of joined members have voted.',
        'VoteParticipationThresholdReached',
      );
      expect(
        (ClosureVotingFailureMapper.mapCancel(threshold) as ServerFailure)
            .message,
        AppStrings.errorContinueContributionThreshold,
      );
    });

    test('cancel 403 is forbidden, not group-leader-cannot-vote', () {
      const cannotVote = ForbiddenFailure('Group Lead cannot vote on this ballot');
      expect(
        (ClosureVotingFailureMapper.map(cannotVote) as ForbiddenFailure).message,
        AppStrings.errorClosureVoteGroupLeaderCannotVote,
      );

      const cancelForbidden = ForbiddenFailure(
        'Only the group leader can cancel this vote.',
        'Forbidden',
      );
      expect(
        (ClosureVotingFailureMapper.mapCancel(cancelForbidden)
                as ForbiddenFailure)
            .message,
        AppStrings.errorForbidden,
      );
    });

    test('maps deployed cancel 404 and 409 codes', () {
      expect(
        (ClosureVotingFailureMapper.mapCancel(
              const ServerFailure(
                'There is no open vote to cancel.',
                'NoOpenVote',
              ),
            ) as ServerFailure)
            .message,
        AppStrings.errorClosureVoteNoOpenVote,
      );
      expect(
        (ClosureVotingFailureMapper.mapCancel(
              const ServerFailure(
                'Continue contribution is no longer available because the voting window has closed.',
                'VoteWindowClosed',
              ),
            ) as ServerFailure)
            .message,
        AppStrings.errorContinueContributionWindowClosed,
      );
      expect(
        (ClosureVotingFailureMapper.mapCancel(
              const ServerFailure(
                'Continue contribution is no longer available because the vote has already been finalized.',
                'VoteAlreadyFinalized',
              ),
            ) as ServerFailure)
            .message,
        AppStrings.errorContinueContributionAlreadyFinalized,
      );
    });

    test('open/cast mapper does not remap cancel window-closed copy', () {
      const failure = ServerFailure(
        'Continue contribution is no longer available because the voting window has closed.',
        'VoteWindowClosed',
      );
      final mapped = ClosureVotingFailureMapper.map(failure);

      expect(
        (mapped as ServerFailure).message,
        'Continue contribution is no longer available because the voting window has closed.',
      );
    });
  });
}
