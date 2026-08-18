import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/continue_contributions_policy.dart';

void main() {
  group('groupLeaderCanContinueContributions', () {
    test('members and co-leaders never pass', () {
      expect(
        groupLeaderCanContinueContributions(
          isGroupLeader: false,
          voteWindowOpen: true,
          totalJoinedMember: 4,
          votesCast: 0,
        ),
        isFalse,
      );
    });

    test('shows below 50% of totalJoinedMember', () {
      expect(
        groupLeaderCanContinueContributions(
          isGroupLeader: true,
          voteWindowOpen: true,
          totalJoinedMember: 4,
          votesCast: 1,
        ),
        isTrue,
      );
      expect(
        groupLeaderCanContinueContributions(
          isGroupLeader: true,
          voteWindowOpen: true,
          totalJoinedMember: 5,
          votesCast: 2,
        ),
        isTrue,
      );
    });

    test('hides at exactly 50% and above', () {
      expect(
        groupLeaderCanContinueContributions(
          isGroupLeader: true,
          voteWindowOpen: true,
          totalJoinedMember: 4,
          votesCast: 2,
        ),
        isFalse,
      );
      expect(
        groupLeaderCanContinueContributions(
          isGroupLeader: true,
          voteWindowOpen: true,
          totalJoinedMember: 5,
          votesCast: 3,
        ),
        isFalse,
      );
    });

    test('hides when joined count is missing and when API flag is false', () {
      expect(
        groupLeaderCanContinueContributions(
          isGroupLeader: true,
          voteWindowOpen: true,
          totalJoinedMember: 0,
          votesCast: 0,
        ),
        isFalse,
      );
      expect(
        groupLeaderCanContinueContributions(
          isGroupLeader: true,
          voteWindowOpen: true,
          totalJoinedMember: 4,
          votesCast: 0,
          apiCanContinueContributions: false,
        ),
        isFalse,
      );
    });

    test('hides when the vote window is not open', () {
      expect(
        groupLeaderCanContinueContributions(
          isGroupLeader: true,
          voteWindowOpen: false,
          totalJoinedMember: 4,
          votesCast: 0,
        ),
        isFalse,
      );
    });
  });
}
