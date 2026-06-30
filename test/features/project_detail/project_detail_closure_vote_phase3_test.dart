import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_closure_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

ProjectDetailEntity _baseProject({
  ViewerMembershipRole role = ViewerMembershipRole.member,
}) {
  return ProjectDetailEntity(
    id: 'p1',
    name: 'Trip',
    category: ProjectCategory.vacations,
    status: ProjectStatus.ongoing,
    goalAmount: 5000,
    currentAmount: 4000,
    endsIn: '2026-12-01',
    announcement: '',
    members: const [],
    borrowRequests: const [],
    viewerRole: role,
  );
}

ActiveClosureVoteEntity _openVote() {
  return ActiveClosureVoteEntity(
    closureVoteId: 'vote-1',
    voteType: ClosureVoteType.successVote,
    status: ClosureVoteStatus.open,
    votingDeadlineUtc: DateTime.utc(2026, 6, 26, 12),
    daysRemaining: 3,
    thumbsUp: 2,
    thumbsDown: 1,
    notYetVoted: 1,
    goalAmount: 5000,
    totalRaised: 4000,
    memberCount: 4,
    callerIsGroupLeader: false,
  );
}

void main() {
  group('ProjectDetailEntity closure vote', () {
    test('withActiveClosureVote sets hasActiveSuccessVote when open', () {
      final enriched = _baseProject().withActiveClosureVote(_openVote());
      expect(enriched.hasActiveSuccessVote, isTrue);
      expect(enriched.activeClosureVote?.thumbsUp, 2);
    });

    test('showsCastVoteAction for member when vote open', () {
      final project = _baseProject().withActiveClosureVote(_openVote());
      expect(project.showsCastVoteAction, isTrue);
    });

    test('showsViewSuccessVotesAction for co-leader when vote open', () {
      final project = _baseProject(
        role: ViewerMembershipRole.coLeader,
      ).withActiveClosureVote(_openVote());
      expect(project.showsViewSuccessVotesAction, isTrue);
    });

    test('group leader cannot cast vote', () {
      final vote = ActiveClosureVoteEntity(
        closureVoteId: 'vote-1',
        voteType: ClosureVoteType.successVote,
        status: ClosureVoteStatus.open,
        votingDeadlineUtc: DateTime.utc(2026, 6, 26),
        daysRemaining: 1,
        thumbsUp: 0,
        thumbsDown: 0,
        notYetVoted: 3,
        goalAmount: 5000,
        totalRaised: 4000,
        memberCount: 3,
        callerIsGroupLeader: true,
      );
      final project = _baseProject(
        role: ViewerMembershipRole.groupLeader,
      ).withActiveClosureVote(vote);
      expect(project.showsViewSuccessVotesAction, isTrue);
      expect(project.showsCastVoteAction, isFalse);
    });

    test('withVotingDetailSnapshot keeps borrow merges from loaded detail', () {
      const borrow = BorrowRequestEntity(
        id: 'br1',
        initials: 'T',
        memberName: 'Test',
        loanType: 'Personal',
        requestedAmount: 50,
        upvotes: 0,
        downvotes: 0,
        status: 'Pending',
      );
      final loaded = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 5000,
        currentAmount: 4000,
        endsIn: '2026-12-01',
        announcement: '',
        members: const [],
        borrowRequests: const [borrow],
        votingStatus: ProjectVotingStatus.pending,
        hasWeek11ProjectDetailEnvelope: true,
        voting: ProjectVotingSummaryEntity(
          startedAtUtc: DateTime.utc(2026, 5, 1),
          deadlineAtUtc: DateTime.utc(2027, 5, 12),
          agreedCount: 0,
          disagreedCount: 0,
          pendingCount: 1,
          memberVotes: const [
            ProjectVotingMemberVoteEntity(
              membershipId: 'm1',
              userId: 'u1',
              displayName: 'Maha',
              status: ProjectMemberVoteStatus.waiting,
            ),
          ],
        ),
      );

      final fresh = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 5000,
        currentAmount: 4000,
        endsIn: '2026-12-01',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        votingStatus: ProjectVotingStatus.pending,
        hasWeek11ProjectDetailEnvelope: true,
        voting: ProjectVotingSummaryEntity(
          startedAtUtc: DateTime.utc(2026, 5, 1),
          deadlineAtUtc: DateTime.utc(2027, 5, 12),
          agreedCount: 1,
          disagreedCount: 0,
          pendingCount: 0,
          memberVotes: const [
            ProjectVotingMemberVoteEntity(
              membershipId: 'm1',
              userId: 'u1',
              displayName: 'Maha',
              status: ProjectMemberVoteStatus.agreed,
            ),
          ],
        ),
      );

      final merged = loaded.withVotingDetailSnapshot(fresh);

      expect(merged.borrowRequests, hasLength(1));
      expect(merged.voting?.agreedCount, 1);
      expect(
        merged.voting?.memberVotes.first.status,
        ProjectMemberVoteStatus.agreed,
      );
    });
  });

  group('closure_vote_ui_mappers', () {
    test('maps active vote to leader progress tallies', () {
      final data = leaderSuccessVoteProgressFromActiveVote(vote: _openVote());
      expect(data.agreedCount, 2);
      expect(data.disagreedCount, 1);
      expect(data.notVotedCount, 1);
      expect(data.majorityRequired, 3);
    });

    test('maps active vote to cast route args', () {
      final project = _baseProject().withActiveClosureVote(_openVote());
      final args = successVoteCastRouteArgsFromProject(project);
      expect(args.projectId, 'p1');
      expect(args.daysRemaining, 3);
      expect(args.thumbsUp, 2);
      expect(args.thumbsDown, 1);
      expect(args.notYetVoted, 1);
    });

    test('maps voting.memberVotes to leader member rows', () {
      final project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 5000,
        currentAmount: 4000,
        endsIn: '2026-12-01',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        voting: ProjectVotingSummaryEntity(
          startedAtUtc: DateTime.utc(2026, 5, 1),
          deadlineAtUtc: DateTime.utc(2026, 5, 12),
          agreedCount: 1,
          disagreedCount: 0,
          pendingCount: 1,
          memberVotes: const [
            ProjectVotingMemberVoteEntity(
              membershipId: 'm1',
              userId: 'u1',
              displayName: 'Maha',
              status: ProjectMemberVoteStatus.agreed,
            ),
            ProjectVotingMemberVoteEntity(
              membershipId: 'm2',
              userId: 'u2',
              displayName: 'James',
              status: ProjectMemberVoteStatus.waiting,
            ),
          ],
        ),
      );

      final data = leaderSuccessVoteProgressFromActiveVote(
        vote: _openVote(),
        project: project,
      );

      expect(data.members, hasLength(2));
      expect(data.members[0].name, 'Maha');
      expect(data.members[0].status, LeaderMemberVoteStatus.agreed);
      expect(data.members[1].status, LeaderMemberVoteStatus.waiting);
    });
  });
}
