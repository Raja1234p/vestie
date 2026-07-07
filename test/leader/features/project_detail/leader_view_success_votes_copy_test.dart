import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';

void main() {
  group('leaderSuccessVoteProgressFromActiveVote', () {
    test('flags stop-contributions monitor copy from vote type', () {
      final data = leaderSuccessVoteProgressFromActiveVote(
        vote: ActiveClosureVoteEntity(
          closureVoteId: 'v1',
          voteType: ClosureVoteType.stopContributionsVote,
          status: ClosureVoteStatus.open,
          votingDeadlineUtc: DateTime.utc(2026, 8, 1),
          daysRemaining: 2,
          thumbsUp: 2,
          thumbsDown: 1,
          notYetVoted: 4,
          goalAmount: 5000,
          totalRaised: 4800,
          memberCount: 7,
        ),
      );

      expect(data.isStopContributionsVote, isTrue);
      expect(data.agreedCount, 2);
      expect(data.disagreedCount, 1);
      expect(data.notVotedCount, 4);
    });
  });

  group('LeaderSuccessVoteMajorityBanner copy', () {
    test('stop-contributions Figma string', () {
      expect(
        AppStrings.leaderSuccessVoteMajorityNeededStopContributions(4, 7),
        'Majority needed: 4 of 7 members must Agree to stop contributions.',
      );
    });
  });
}
