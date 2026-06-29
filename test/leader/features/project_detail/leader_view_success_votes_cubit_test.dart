import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/usecases/closure_voting_usecases.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_active_closure_vote_usecase.dart';
import 'package:vestie/leader/features/project_detail/presentation/cubit/leader_view_success_votes_cubit.dart';
import 'package:vestie/leader/features/project_detail/presentation/cubit/leader_view_success_votes_state.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';

class _MockGetActive extends Mock implements GetActiveClosureVoteUseCase {}

class _MockFinalize extends Mock implements FinalizeClosureVotingUseCase {}

void main() {
  late _MockGetActive getActive;
  late _MockFinalize finalize;

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

  final args = LeaderViewSuccessVotesRouteArgs(
    projectName: 'Trip',
    projectId: 'p1',
    data: seedData,
  );

  setUp(() {
    getActive = _MockGetActive();
    finalize = _MockFinalize();
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
    getActiveClosureVoteUseCase: getActive,
    finalizeClosureVotingUseCase: finalize,
  );

  test('load emits tallies from active vote', () async {
    when(() => getActive('p1')).thenAnswer((_) async => Right(openVote()));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    final loadFuture = cubit.load();
    expect(cubit.state.loadStatus, LeaderViewSuccessVotesLoadStatus.loading);

    await loadFuture;

    expect(cubit.state.loadStatus, LeaderViewSuccessVotesLoadStatus.loaded);
    expect(cubit.state.data?.agreedCount, 2);
    expect(cubit.state.data?.members.first.name, 'Anna');
    expect(cubit.state.canFinalize, isFalse);
  });

  test('canFinalize when GL and deadline passed', () async {
    when(() => getActive('p1')).thenAnswer(
      (_) async => Right(
        openVote(
          callerIsGroupLeader: true,
          deadline: DateTime.utc(2020, 1, 1),
        ),
      ),
    );

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.canFinalize, isTrue);
  });

  test('finalizeVote calls use case', () async {
    when(() => getActive('p1')).thenAnswer(
      (_) async => Right(
        openVote(
          callerIsGroupLeader: true,
          deadline: DateTime.utc(2020, 1, 1),
        ),
      ),
    );
    when(() => finalize(projectId: 'p1')).thenAnswer(
      (_) async => const Right(
        FinalizeClosureVoteResultEntity(
          closureVoteId: 'v1',
          voteType: ClosureVoteType.successVote,
          outcome: ClosureVoteOutcome.success,
          thumbsUp: 2,
          thumbsDown: 1,
          notYetVoted: 0,
          projectStatus: 'Successful',
        ),
      ),
    );

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();
    final result = await cubit.finalizeVote();

    expect(result, isNotNull);
    verify(() => finalize(projectId: 'p1')).called(1);
    expect(cubit.state.canFinalize, isFalse);
  });
}
