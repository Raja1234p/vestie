import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_active_closure_vote_usecase.dart';
import 'package:vestie/leader/features/project_detail/presentation/cubit/leader_view_success_votes_cubit.dart';
import 'package:vestie/leader/features/project_detail/presentation/cubit/leader_view_success_votes_state.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

class _MockProjectDetailRepository extends Mock
    implements ProjectDetailRepository {}

class _MockGetActive extends Mock implements GetActiveClosureVoteUseCase {}

void main() {
  late _MockProjectDetailRepository projectDetailRepository;
  late _MockGetActive getActive;

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
      votingStatus: votingStatus,
      detailUserRole: ProjectDetailUserRole.leader,
      hasWeek11ProjectDetailEnvelope: true,
      voting: ProjectVotingSummaryEntity(
        startedAtUtc: DateTime.utc(2026, 5, 1, 10),
        deadlineAtUtc:
            deadlineAtUtc ?? DateTime.utc(2027, 5, 12, 23, 59, 59),
        agreedCount: agreedCount,
        disagreedCount: disagreedCount,
        pendingCount: pendingCount,
        memberVotes: memberVotes,
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
}
