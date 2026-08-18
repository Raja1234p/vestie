import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_active_closure_vote_usecase.dart';
import 'package:vestie/features/project_detail/domain/usecases/closure_voting_usecases.dart';
import 'package:vestie/leader/features/project_detail/presentation/cubit/leader_view_success_votes_cubit.dart';
import 'package:vestie/leader/features/project_detail/presentation/cubit/leader_view_success_votes_state.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

class _MockProjectDetailRepository extends Mock
    implements ProjectDetailRepository {}

class _MockGetActive extends Mock implements GetActiveClosureVoteUseCase {}

class _MockCancelVote extends Mock implements CancelClosureVotingUseCase {}

void main() {
  late _MockProjectDetailRepository projectDetailRepository;
  late _MockGetActive getActive;
  late _MockCancelVote cancelVote;

  const seedData = LeaderSuccessVoteProgressUiData(
    agreedCount: 1,
    disagreedCount: 0,
    notVotedCount: 2,
    majorityRequired: 2,
    totalMembers: 3,
    remaining: Duration(hours: 1),
    members: [
      LeaderSuccessVoteMemberRow(
        name: 'Anna',
        status: LeaderMemberVoteStatus.waiting,
      ),
    ],
  );

  ProjectDetailEntity projectWithVoting({
    List<ProjectVotingMemberVoteEntity> memberVotes = const [
      ProjectVotingMemberVoteEntity(
        membershipId: 'm1',
        userId: 'u1',
        displayName: 'Anna',
        status: ProjectMemberVoteStatus.agreed,
      ),
    ],
    int agreedCount = 2,
    int disagreedCount = 1,
    int pendingCount = 0,
    DateTime? deadlineAtUtc,
    ProjectVotingStatus votingStatus = ProjectVotingStatus.pending,
    ViewerMembershipRole viewerRole = ViewerMembershipRole.member,
    ProjectDetailUserRole detailUserRole = ProjectDetailUserRole.leader,
    int totalJoinedMember = 0,
    bool? canContinueContributions,
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
      viewerRole: viewerRole,
      totalJoinedMember: totalJoinedMember,
      votingStatus: votingStatus,
      detailUserRole: detailUserRole,
      hasWeek11ProjectDetailEnvelope: true,
      voting: ProjectVotingSummaryEntity(
        startedAtUtc: DateTime.utc(2026, 5, 1, 10),
        deadlineAtUtc:
            deadlineAtUtc ?? DateTime.utc(2027, 5, 12, 23, 59, 59),
        agreedCount: agreedCount,
        disagreedCount: disagreedCount,
        pendingCount: pendingCount,
        memberVotes: memberVotes,
        canContinueContributions: canContinueContributions,
      ),
    );
  }

  final args = LeaderViewSuccessVotesRouteArgs(
    projectName: 'Trip',
    projectId: 'p1',
    data: seedData,
    project: projectWithVoting(),
  );

  setUp(() {
    projectDetailRepository = _MockProjectDetailRepository();
    getActive = _MockGetActive();
    cancelVote = _MockCancelVote();
  });

  ActiveClosureVoteEntity openVote({
    bool callerIsGroupLeader = false,
    DateTime? deadline,
  }) {
    return ActiveClosureVoteEntity(
      closureVoteId: 'v1',
      voteType: ClosureVoteType.successVote,
      status: ClosureVoteStatus.open,
      votingDeadlineUtc: deadline ?? DateTime.utc(2026, 6, 26, 12),
      daysRemaining: 3,
      thumbsUp: 2,
      thumbsDown: 1,
      notYetVoted: 0,
      goalAmount: 5000,
      totalRaised: 4000,
      memberCount: 3,
      callerIsGroupLeader: callerIsGroupLeader,
    );
  }

  LeaderViewSuccessVotesCubit buildCubit() => LeaderViewSuccessVotesCubit(
    args: args,
    projectDetailRepository: projectDetailRepository,
    getActiveClosureVoteUseCase: getActive,
    cancelClosureVotingUseCase: cancelVote,
  );

  test('load uses GET /projects/{id} voting when Week 11 envelope is active',
      () async {
    final project = projectWithVoting();
    when(
      () => projectDetailRepository.getProjectDetail(projectId: 'p1'),
    ).thenAnswer((_) async => Right(project));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.loadStatus, LeaderViewSuccessVotesLoadStatus.loaded);
    expect(cubit.state.data?.agreedCount, 2);
    expect(cubit.state.data?.members.first.name, 'Anna');
    expect(
      cubit.state.data?.members.first.status,
      LeaderMemberVoteStatus.agreed,
    );
    verifyNever(() => getActive(any()));
    verifyNever(() => cancelVote(projectId: 'p1'));
  });

  test('load falls back to active vote for legacy detail without voting envelope',
      () async {
    final legacyProject = ProjectDetailEntity(
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
      hasWeek11ProjectDetailEnvelope: false,
    );
    when(
      () => projectDetailRepository.getProjectDetail(projectId: 'p1'),
    ).thenAnswer((_) async => Right(legacyProject));
    when(() => getActive('p1')).thenAnswer((_) async => Right(openVote()));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.loadStatus, LeaderViewSuccessVotesLoadStatus.loaded);
    expect(cubit.state.data?.agreedCount, 2);
    verify(() => getActive('p1')).called(1);
  });

  test('load keeps finalized stop-contributions tallies after voting ends',
      () async {
    final project = ProjectDetailEntity(
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
      displayStatusLabel: 'Funded',
      projectLifecycleState: 'funded',
      votingStatus: ProjectVotingStatus.done,
      detailUserRole: ProjectDetailUserRole.leader,
      hasWeek11ProjectDetailEnvelope: true,
      voting: ProjectVotingSummaryEntity(
        startedAtUtc: DateTime.utc(2026, 6, 1),
        deadlineAtUtc: DateTime.utc(2026, 6, 30),
        agreedCount: 5,
        disagreedCount: 1,
        pendingCount: 0,
        isFinalized: true,
        voteType: ClosureVoteType.stopContributionsVote,
        outcome: ClosureVoteOutcome.investmentStarted,
        isApproved: true,
        memberVotes: const [
          ProjectVotingMemberVoteEntity(
            membershipId: 'm1',
            userId: 'u1',
            displayName: 'Anna',
            status: ProjectMemberVoteStatus.agreed,
          ),
        ],
      ),
    );
    when(
      () => projectDetailRepository.getProjectDetail(projectId: 'p1'),
    ).thenAnswer((_) async => Right(project));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.loadStatus, LeaderViewSuccessVotesLoadStatus.loaded);
    expect(cubit.state.data?.agreedCount, 5);
    expect(cubit.state.data?.disagreedCount, 1);
    verifyNever(() => getActive(any()));
  });

  test('continueContributions is blocked for members', () async {
    final project = projectWithVoting(
      viewerRole: ViewerMembershipRole.member,
      totalJoinedMember: 4,
      agreedCount: 0,
      disagreedCount: 0,
      pendingCount: 3,
    );
    when(
      () => projectDetailRepository.getProjectDetail(projectId: 'p1'),
    ).thenAnswer((_) async => Right(project));

    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.load();

    expect(cubit.state.data?.showContinueContributions, isFalse);
    expect(await cubit.continueContributions(), isFalse);
    verifyNever(() => cancelVote(projectId: 'p1'));
  });

  test('continueContributions is blocked for co-leaders', () async {
    final project = projectWithVoting(
      viewerRole: ViewerMembershipRole.coLeader,
      totalJoinedMember: 4,
      agreedCount: 0,
      disagreedCount: 0,
      pendingCount: 3,
      detailUserRole: ProjectDetailUserRole.coLeader,
    );
    when(
      () => projectDetailRepository.getProjectDetail(projectId: 'p1'),
    ).thenAnswer((_) async => Right(project));

    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.load();

    expect(cubit.state.data?.showContinueContributions, isFalse);
    expect(await cubit.continueContributions(), isFalse);
    verifyNever(() => cancelVote(projectId: 'p1'));
  });

  test(
    'continueContributions does not change majority (eligible voters, not joined)',
    () async {
      final project = projectWithVoting(
        viewerRole: ViewerMembershipRole.groupLeader,
        totalJoinedMember: 10,
        agreedCount: 1,
        disagreedCount: 0,
        pendingCount: 2,
        memberVotes: const [
          ProjectVotingMemberVoteEntity(
            membershipId: 'm1',
            userId: 'u1',
            displayName: 'Anna',
            status: ProjectMemberVoteStatus.agreed,
          ),
          ProjectVotingMemberVoteEntity(
            membershipId: 'm2',
            userId: 'u2',
            displayName: 'Ben',
            status: ProjectMemberVoteStatus.waiting,
          ),
          ProjectVotingMemberVoteEntity(
            membershipId: 'm3',
            userId: 'u3',
            displayName: 'Cara',
            status: ProjectMemberVoteStatus.waiting,
          ),
        ],
      );
      when(
        () => projectDetailRepository.getProjectDetail(projectId: 'p1'),
      ).thenAnswer((_) async => Right(project));

      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.load();

      expect(cubit.state.data?.showContinueContributions, isTrue);
      expect(cubit.state.data?.totalMembers, 3);
      expect(cubit.state.data?.majorityRequired, 2);
    },
  );

  test('continueContributions posts cancel then reloads for group leader',
      () async {
    final project = projectWithVoting(
      viewerRole: ViewerMembershipRole.groupLeader,
      totalJoinedMember: 4,
      agreedCount: 1,
      disagreedCount: 0,
      pendingCount: 2,
    );
    when(
      () => projectDetailRepository.getProjectDetail(projectId: 'p1'),
    ).thenAnswer((_) async => Right(project));
    when(
      () => cancelVote(projectId: 'p1'),
    ).thenAnswer(
      (_) async => const Right(CancelClosureVoteResultEntity()),
    );

    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.load();

    expect(cubit.state.data?.showContinueContributions, isTrue);
    expect(await cubit.continueContributions(), isTrue);
    verify(() => cancelVote(projectId: 'p1')).called(1);
  });

  test('continueContributions 409 reloads monitor from GET detail', () async {
    final belowThreshold = projectWithVoting(
      viewerRole: ViewerMembershipRole.groupLeader,
      totalJoinedMember: 4,
      agreedCount: 1,
      disagreedCount: 0,
      pendingCount: 2,
    );
    final atThreshold = projectWithVoting(
      viewerRole: ViewerMembershipRole.groupLeader,
      totalJoinedMember: 4,
      agreedCount: 1,
      disagreedCount: 1,
      pendingCount: 1,
    );
    var detailCalls = 0;
    when(
      () => projectDetailRepository.getProjectDetail(projectId: 'p1'),
    ).thenAnswer((_) async {
      detailCalls += 1;
      return Right(detailCalls == 1 ? belowThreshold : atThreshold);
    });
    when(
      () => cancelVote(projectId: 'p1'),
    ).thenAnswer(
      (_) async => const Left(
        ServerFailure(
          'Continue contribution is no longer available because at least 50% of joined members have voted.',
          'VoteParticipationThresholdReached',
        ),
      ),
    );

    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.load();

    expect(cubit.state.data?.showContinueContributions, isTrue);
    expect(await cubit.continueContributions(), isFalse);
    expect(cubit.state.data?.showContinueContributions, isFalse);
    verify(() => cancelVote(projectId: 'p1')).called(1);
    verify(() => projectDetailRepository.getProjectDetail(projectId: 'p1'))
        .called(2);
  });

  test('continueContributions hides at 50% of totalJoinedMember', () async {
    final project = projectWithVoting(
      viewerRole: ViewerMembershipRole.groupLeader,
      totalJoinedMember: 4,
      agreedCount: 1,
      disagreedCount: 1,
      pendingCount: 1,
    );
    when(
      () => projectDetailRepository.getProjectDetail(projectId: 'p1'),
    ).thenAnswer((_) async => Right(project));

    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.load();

    expect(cubit.state.data?.showContinueContributions, isFalse);
    expect(await cubit.continueContributions(), isFalse);
    verifyNever(() => cancelVote(projectId: 'p1'));
  });
}
