import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/data/models/project_detail_response_model.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_closure_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

ProjectDetailEntity _leaderProject(
  ProjectCategory category, {
  bool? apiCanStopContributions,
}) {
  return ProjectDetailEntity(
    id: 'p1',
    name: 'Test',
    category: category,
    status: ProjectStatus.ongoing,
    goalAmount: 1000,
    currentAmount: 0,
    endsIn: '30d',
    announcement: '',
    members: const [],
    borrowRequests: const [],
    viewerRole: ViewerMembershipRole.groupLeader,
    apiCanStopContributions: apiCanStopContributions,
  );
}

void main() {
  group('ProjectDetailEntity.canStopContributions', () {
    test('true for group leader on investment when API allows', () {
      expect(
        _leaderProject(
          ProjectCategory.investment,
          apiCanStopContributions: true,
        ).canStopContributions,
        isTrue,
      );
    });

    test('false when API canStopContributions is false', () {
      expect(
        _leaderProject(
          ProjectCategory.investment,
          apiCanStopContributions: false,
        ).canStopContributions,
        isFalse,
      );
    });

    test('legacy true for group leader on investment when API omits field', () {
      expect(_leaderProject(ProjectCategory.investment).canStopContributions,
          isTrue);
    });

    test('false for group leader on vacation and emergency projects', () {
      expect(_leaderProject(ProjectCategory.vacations).canStopContributions,
          isFalse);
      expect(_leaderProject(ProjectCategory.emergency).canStopContributions,
          isFalse);
    });

    test('false for co-leader even on investment', () {
      final project = ProjectDetailEntity(
        id: 'p1',
        name: 'Test',
        category: ProjectCategory.investment,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 0,
        endsIn: '30d',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        viewerRole: ViewerMembershipRole.coLeader,
        apiCanStopContributions: true,
      );

      expect(project.canStopContributions, isFalse);
    });
  });

  group('ProjectDetailEntity.canMarkProjectSuccessful', () {
    test('hidden while API canStopContributions is true', () {
      expect(
        _leaderProject(
          ProjectCategory.investment,
          apiCanStopContributions: true,
        ).canMarkProjectSuccessful,
        isFalse,
      );
    });

    test('shown when API canStopContributions is false', () {
      expect(
        _leaderProject(
          ProjectCategory.investment,
          apiCanStopContributions: false,
        ).canMarkProjectSuccessful,
        isTrue,
      );
    });

    test('legacy shown for leader when API omits field', () {
      expect(
        _leaderProject(ProjectCategory.vacations).canMarkProjectSuccessful,
        isTrue,
      );
    });

    test('shown for vacation leader even when API canStopContributions is true',
        () {
      expect(
        _leaderProject(
          ProjectCategory.vacations,
          apiCanStopContributions: true,
        ).canMarkProjectSuccessful,
        isTrue,
      );
    });
  });

  group('ProjectDetailResponseModel canStopContributions', () {
    test('parses root canStopContributions from GET project detail', () {
      final entity = ProjectDetailResponseModel.fromJson({
        'project': {
          'id': 'p1',
          'name': 'Fund',
          'description': '',
          'type': 'investment',
          'visibility': 'private',
          'state': 'active',
          'targetAmount': 10000,
          'raisedAmount': 5000,
          'endsAtUtc': '2026-12-31T00:00:00Z',
          'viewerRole': 'GroupLeader',
        },
        'rules': {},
        'viewerMembership': {
          'membershipId': 'm1',
          'userId': 'u1',
          'userName': 'leader',
          'firstName': 'L',
          'lastName': 'E',
          'role': 'leader',
          'status': 'active',
        },
        'members': [],
        'invites': [],
        'announcements': [],
        'projectStatus': 'ongoing',
        'userRole': 'leader',
        'canStopContributions': false,
      }).toEntity();

      expect(entity.apiCanStopContributions, isFalse);
      expect(entity.canStopContributions, isFalse);
      expect(entity.canMarkProjectSuccessful, isTrue);
    });
  });

  group('ProjectDetailEntity.showsViewContributionSuccessVoteAction', () {
    test('true for investment group leader during stop-contributions vote', () {
      final project = _leaderProject(
        ProjectCategory.investment,
        apiCanStopContributions: true,
      ).copyWithWeek11Voting(
        votingStatus: ProjectVotingStatus.pending,
        detailUserRole: ProjectDetailUserRole.leader,
      );

      expect(project.showsViewContributionSuccessVoteAction, isTrue);
      expect(project.isStopContributionsClosureVote, isTrue);
    });

    test('false for investment group leader during mark-successful vote', () {
      final project = _leaderProject(
        ProjectCategory.investment,
        apiCanStopContributions: false,
      ).copyWithWeek11Voting(
        votingStatus: ProjectVotingStatus.pending,
        detailUserRole: ProjectDetailUserRole.leader,
      );

      expect(project.showsViewContributionSuccessVoteAction, isFalse);
      expect(project.isStopContributionsClosureVote, isFalse);
    });

    test('false for co-leader during stop-contributions vote', () {
      final project = ProjectDetailEntity(
        id: 'p1',
        name: 'Fund',
        category: ProjectCategory.investment,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 500,
        endsIn: '30d',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        viewerRole: ViewerMembershipRole.coLeader,
        apiCanStopContributions: true,
        hasWeek11ProjectDetailEnvelope: true,
        detailUserRole: ProjectDetailUserRole.coLeader,
        votingStatus: ProjectVotingStatus.pending,
        voting: ProjectVotingSummaryEntity(
          startedAtUtc: DateTime.utc(2026, 6, 1),
          deadlineAtUtc: DateTime.utc(2026, 7, 1),
          agreedCount: 1,
          disagreedCount: 0,
          pendingCount: 2,
          hasVoted: false,
          isFinalized: false,
        ),
        hasActiveSuccessVote: true,
      ).withSyntheticClosureVoteFromDetailVoting();

      expect(project.showsViewContributionSuccessVoteAction, isFalse);
    });
  });
}

extension on ProjectDetailEntity {
  ProjectDetailEntity copyWithWeek11Voting({
    required ProjectVotingStatus votingStatus,
    required ProjectDetailUserRole detailUserRole,
  }) {
    final deadline = DateTime.utc(2026, 7, 1);
  return ProjectDetailEntity(
      id: id,
      name: name,
      category: category,
      status: status,
      goalAmount: goalAmount,
      currentAmount: currentAmount,
      endsIn: endsIn,
      announcement: announcement,
      members: members,
      borrowRequests: borrowRequests,
      viewerRole: viewerRole,
      apiCanStopContributions: apiCanStopContributions,
      hasWeek11ProjectDetailEnvelope: true,
      detailUserRole: detailUserRole,
      votingStatus: votingStatus,
      voting: ProjectVotingSummaryEntity(
        startedAtUtc: DateTime.utc(2026, 6, 1),
        deadlineAtUtc: deadline,
        agreedCount: 1,
        disagreedCount: 0,
        pendingCount: 2,
        hasVoted: false,
        isFinalized: false,
      ),
      hasActiveSuccessVote: true,
    ).withSyntheticClosureVoteFromDetailVoting();
  }
}
