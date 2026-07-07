import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/data/models/project_detail_response_model.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_closure_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_completed_outcome_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

ProjectDetailEntity _leaderProject(
  ProjectCategory category, {
  bool? apiCanStopContributions,
  String displayStatusLabel = '',
  String projectLifecycleState = '',
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
    displayStatusLabel: displayStatusLabel,
    projectLifecycleState: projectLifecycleState,
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

    test('hidden while stop-contributions vote is pending', () {
      final project = _leaderProject(
        ProjectCategory.investment,
        apiCanStopContributions: true,
      ).copyWithWeek11Voting(
        votingStatus: ProjectVotingStatus.pending,
        detailUserRole: ProjectDetailUserRole.leader,
      );

      expect(project.votingIsInProgress, isTrue);
      expect(project.hasActiveClosureVotingWindow, isTrue);
      expect(project.canMarkProjectSuccessful, isFalse);
    });

    test('hidden while vote is done but not finalized', () {
      final project = _leaderProject(
        ProjectCategory.investment,
        apiCanStopContributions: true,
      ).copyWithWeek11Voting(
        votingStatus: ProjectVotingStatus.done,
        detailUserRole: ProjectDetailUserRole.leader,
      );

      expect(project.votingIsInProgress, isTrue);
      expect(project.canMarkProjectSuccessful, isFalse);
    });

    test(
      'shown after stop-contributions vote is finalized '
      '(canStopContributions false)',
      () {
        final project = _leaderProject(
          ProjectCategory.investment,
          apiCanStopContributions: false,
        ).copyWithWeek11Voting(
          votingStatus: ProjectVotingStatus.done,
          detailUserRole: ProjectDetailUserRole.leader,
          isFinalized: true,
        );

        expect(project.votingIsInProgress, isFalse);
        expect(project.hasActiveClosureVotingWindow, isFalse);
        expect(project.canMarkProjectSuccessful, isTrue);
      },
    );
  });

  group('ProjectDetailEntity.canInviteMembers', () {
    test('true for leader while contributions are open', () {
      expect(
        _leaderProject(
          ProjectCategory.investment,
          apiCanStopContributions: true,
        ).canInviteMembers,
        isTrue,
      );
    });

    test('false after stop-contributions (investment funded)', () {
      expect(
        _leaderProject(
          ProjectCategory.investment,
          apiCanStopContributions: false,
          displayStatusLabel: 'Funded',
        ).canInviteMembers,
        isFalse,
      );
    });

    test('false during mark-successful / closure vote', () {
      final project = _leaderProject(ProjectCategory.vacations).copyWithWeek11Voting(
        votingStatus: ProjectVotingStatus.pending,
        detailUserRole: ProjectDetailUserRole.leader,
      );

      expect(project.canInviteMembers, isFalse);
    });

    test('false when displayStatus is Closure Voting', () {
      final project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 500,
        endsIn: '30d',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        viewerRole: ViewerMembershipRole.member,
        displayStatusLabel: 'Closure Voting',
      );

      expect(project.canInviteMembers, isFalse);
    });

    test('false for member during stop-contributions vote', () {
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
        viewerRole: ViewerMembershipRole.member,
        apiCanStopContributions: true,
      ).copyWithWeek11Voting(
        votingStatus: ProjectVotingStatus.pending,
        detailUserRole: ProjectDetailUserRole.member,
      );

      expect(project.canInviteMembers, isFalse);
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

    test(
      'finalized done vote does not keep active window '
      '(unlocks Mark as Successful)',
      () {
        final entity = ProjectDetailResponseModel.fromJson({
          'project': {
            'id': 'p1',
            'name': '144&215',
            'description': '',
            'type': 'investment',
            'visibility': 'private',
            'state': 'active',
            'targetAmount': 10000,
            'raisedAmount': 10000,
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
          'votingStatus': 'done',
          'voting': {
            'startedAtUtc': '2026-06-01T00:00:00Z',
            'deadlineAtUtc': '2026-07-01T00:00:00Z',
            'agreedCount': 2,
            'disagreedCount': 0,
            'pendingCount': 0,
            'hasVoted': true,
            'isFinalized': true,
          },
        }).toEntity();

        expect(entity.hasActiveSuccessVote, isFalse);
        expect(entity.votingIsInProgress, isFalse);
        expect(entity.hasActiveClosureVotingWindow, isFalse);
        expect(entity.canMarkProjectSuccessful, isTrue);
      },
    );
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
      expect(project.canCancelProject, isFalse);
    });

    test('false for investment group leader during mark-successful vote', () {
      final project = _leaderProject(
        ProjectCategory.investment,
        apiCanStopContributions: false,
        displayStatusLabel: 'Funded',
      ).copyWithWeek11Voting(
        votingStatus: ProjectVotingStatus.pending,
        detailUserRole: ProjectDetailUserRole.leader,
      );

      expect(project.isStopContributionsClosureVote, isFalse);
      expect(project.showsLeaderViewSuccessVotesAction, isTrue);
      expect(project.isInvestmentMarkSuccessfulClosureVote, isTrue);
      expect(
        project.activeClosureVote?.voteType,
        ClosureVoteType.finalClosureVote,
      );
    });

    test(
      'true for investment member during stop-contributions vote '
      'when canStopContributions is already false',
      () {
        final project = ProjectDetailEntity(
          id: 'p1',
          name: 'Fund',
          category: ProjectCategory.investment,
          status: ProjectStatus.ongoing,
          goalAmount: 5000,
          currentAmount: 4800,
          endsIn: '30d',
          announcement: '',
          members: const [],
          borrowRequests: const [],
          viewerRole: ViewerMembershipRole.member,
          apiCanStopContributions: false,
          hasWeek11ProjectDetailEnvelope: true,
          detailUserRole: ProjectDetailUserRole.member,
          votingStatus: ProjectVotingStatus.pending,
          voting: ProjectVotingSummaryEntity(
            startedAtUtc: DateTime.utc(2026, 5, 1),
            deadlineAtUtc: DateTime.utc(2026, 5, 12),
            agreedCount: 4,
            disagreedCount: 2,
            pendingCount: 5,
            hasVoted: false,
            isFinalized: false,
          ),
          hasActiveSuccessVote: true,
        ).withSyntheticClosureVoteFromDetailVoting();

        expect(project.isStopContributionsClosureVote, isTrue);
        expect(project.showsInlineMemberCastVote, isTrue);
        expect(
          project.activeClosureVote?.voteType,
          ClosureVoteType.stopContributionsVote,
        );
      },
    );

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

  group('ProjectDetailEntity.showsContributeAction', () {
    ProjectDetailEntity memberInvestment({
      bool? apiCanStopContributions,
      String projectLifecycleState = '',
      String displayStatusLabel = '',
    }) {
      return ProjectDetailEntity(
        id: 'p1',
        name: 'Fund',
        category: ProjectCategory.investment,
        status: ProjectStatus.ongoing,
        goalAmount: 10000,
        currentAmount: 5000,
        endsIn: '30d',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        viewerRole: ViewerMembershipRole.member,
        apiCanStopContributions: apiCanStopContributions,
        projectLifecycleState: projectLifecycleState,
        displayStatusLabel: displayStatusLabel,
      );
    }

    test('true for investment member while contribution phase is open', () {
      expect(
        memberInvestment(apiCanStopContributions: true).showsContributeAction,
        isTrue,
      );
    });

    test('false after stop-contributions vote closes contribution phase', () {
      expect(
        memberInvestment(
          apiCanStopContributions: false,
          displayStatusLabel: 'Funded',
        ).showsContributeAction,
        isFalse,
      );
    });

    test('false when project lifecycle is funded', () {
      expect(
        memberInvestment(projectLifecycleState: 'funded').showsContributeAction,
        isFalse,
      );
    });

    test('still true for vacation member regardless of canStopContributions',
        () {
      final project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 0,
        endsIn: '30d',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        viewerRole: ViewerMembershipRole.member,
        apiCanStopContributions: false,
      );

      expect(project.showsContributeAction, isTrue);
    });
  });

  group('ProjectDetailEntity.showsInvestmentDistributionActions', () {
    ProjectDetailEntity investmentProject({
      ProjectStatus status = ProjectStatus.ongoing,
      bool? apiCanStopContributions,
      String projectLifecycleState = '',
      ProjectVotingStatus votingStatus = ProjectVotingStatus.notStarted,
      bool isFinalized = false,
    }) {
      return ProjectDetailEntity(
        id: 'p1',
        name: 'Fund',
        category: ProjectCategory.investment,
        status: status,
        goalAmount: 10000,
        currentAmount: 5000,
        endsIn: '30d',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        viewerRole: ViewerMembershipRole.groupLeader,
        apiCanStopContributions: apiCanStopContributions,
        projectLifecycleState: projectLifecycleState,
        votingStatus: votingStatus,
        hasWeek11ProjectDetailEnvelope: true,
        detailUserRole: ProjectDetailUserRole.leader,
        voting: votingStatus == ProjectVotingStatus.notStarted
            ? null
            : ProjectVotingSummaryEntity(
                startedAtUtc: DateTime.utc(2026, 6, 1),
                deadlineAtUtc: DateTime.utc(2026, 6, 30),
                agreedCount: 2,
                disagreedCount: 0,
                pendingCount: 0,
                isFinalized: isFinalized,
              ),
      );
    }

    test('hidden while stop-contributions vote is in progress', () {
      expect(
        investmentProject(
          apiCanStopContributions: true,
          votingStatus: ProjectVotingStatus.pending,
        ).showsInvestmentDistributionActions,
        isFalse,
      );
    });

    test('shown after stop-contributions vote succeeds (funded, vote finalized)',
        () {
      expect(
        investmentProject(
          apiCanStopContributions: false,
          projectLifecycleState: 'funded',
          votingStatus: ProjectVotingStatus.done,
          isFinalized: true,
        ).showsInvestmentDistributionActions,
        isTrue,
      );
    });

    test('hidden when project is completed', () {
      expect(
        investmentProject(
          status: ProjectStatus.completed,
          apiCanStopContributions: false,
          projectLifecycleState: 'funded',
        ).showsInvestmentDistributionActions,
        isFalse,
      );
    });

    test('hidden for vacation projects', () {
      final project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.completed,
        goalAmount: 1000,
        currentAmount: 1000,
        endsIn: '30d',
        announcement: '',
        members: const [],
        borrowRequests: const [],
      );

      expect(project.showsInvestmentDistributionActions, isFalse);
    });
  });

  group('ProjectDetailEntity completed vote outcome', () {
    test('shows outcome UI when project is completed', () {
      final project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.completed,
        goalAmount: 1000,
        currentAmount: 900,
        endsIn: '30d',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        projectBannerStatus: ProjectDetailBannerStatus.completed,
      );

      expect(project.showsCompletedProjectVoteOutcome, isTrue);
      expect(project.isClosureVoteOutcomeApproved, isTrue);
    });

    test('refund outcome when display status contains refund', () {
      final project = ProjectDetailEntity(
        id: 'p1',
        name: 'Fund',
        category: ProjectCategory.investment,
        status: ProjectStatus.completed,
        goalAmount: 1000,
        currentAmount: 900,
        endsIn: '30d',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        displayStatusLabel: 'Refund in progress',
        projectBannerStatus: ProjectDetailBannerStatus.cancelled,
      );

      expect(project.isClosureVoteOutcomeApproved, isFalse);
      expect(project.showsClosureVoteRefundOutcome, isTrue);
    });
  });
}

extension on ProjectDetailEntity {
  ProjectDetailEntity copyWithWeek11Voting({
    required ProjectVotingStatus votingStatus,
    required ProjectDetailUserRole detailUserRole,
    bool isFinalized = false,
  }) {
    final deadline = DateTime.utc(2026, 7, 1);
    final entity = ProjectDetailEntity(
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
      displayStatusLabel: displayStatusLabel,
      projectLifecycleState: projectLifecycleState,
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
        isFinalized: isFinalized,
      ),
      hasActiveSuccessVote: !isFinalized &&
          (votingStatus == ProjectVotingStatus.pending ||
              votingStatus == ProjectVotingStatus.done),
    );
    if (!entity.votingIsInProgress) return entity;
    return entity.withSyntheticClosureVoteFromDetailVoting();
  }
}
