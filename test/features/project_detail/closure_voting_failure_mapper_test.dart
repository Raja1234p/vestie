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
  });
}
