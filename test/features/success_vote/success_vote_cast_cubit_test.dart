import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_active_closure_vote_usecase.dart';
import 'package:vestie/features/project_detail/domain/usecases/submit_vote_usecase.dart';
import 'package:vestie/features/success_vote/presentation/cubit/success_vote_cast_cubit.dart';
import 'package:vestie/features/success_vote/presentation/cubit/success_vote_cast_state.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_choice.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_route_args.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

class _MockGetActive extends Mock implements GetActiveClosureVoteUseCase {}

class _MockSubmit extends Mock implements SubmitVoteUseCase {}

void main() {
  late _MockGetActive getActive;
  late _MockSubmit submit;
  late SuccessVoteCastRouteArgs args;

  setUpAll(() {
    registerFallbackValue(
      const SubmitVoteParams(projectId: 'p1', isPositive: true),
    );
  });

  setUp(() {
    getActive = _MockGetActive();
    submit = _MockSubmit();
    args = const SuccessVoteCastRouteArgs(
      projectId: 'p1',
      projectName: 'Trip',
      projectCategory: ProjectCategory.vacations,
      goalAmount: 5000,
      memberCount: 4,
      totalRaised: 4000,
      deadlineLabel: 'Jun 1',
      daysRemaining: 5,
    );
  });

  ActiveClosureVoteEntity openVote({ClosureVoteValue? callerVote}) {
    return ActiveClosureVoteEntity(
      closureVoteId: 'v1',
      voteType: ClosureVoteType.successVote,
      status: ClosureVoteStatus.open,
      votingDeadlineUtc: DateTime.utc(2026, 6, 26),
      daysRemaining: 5,
      thumbsUp: 2,
      thumbsDown: 1,
      notYetVoted: 1,
      goalAmount: 5000,
      totalRaised: 4000,
      memberCount: 4,
      callerVote: callerVote,
    );
  }

  SuccessVoteCastCubit buildCubit() => SuccessVoteCastCubit(
    args: args,
    getActiveClosureVoteUseCase: getActive,
    submitVoteUseCase: submit,
  );

  test('load emits tallies from active vote', () async {
    when(() => getActive('p1')).thenAnswer((_) async => Right(openVote()));

    final cubit = buildCubit();
    addTearDown(cubit.close);

    final loadFuture = cubit.load();
    expect(cubit.state.loadStatus, SuccessVoteCastLoadStatus.loading);

    await loadFuture;

    expect(cubit.state.loadStatus, SuccessVoteCastLoadStatus.loaded);
    expect(cubit.state.data?.thumbsUp, 2);
    expect(cubit.state.canVote, isTrue);
  });

  test('submitVote updates tallies and choice', () async {
    when(() => getActive('p1')).thenAnswer((_) async => Right(openVote()));
    when(() => submit(any())).thenAnswer(
      (_) async => const Right(
        CastClosureVoteResultEntity(
          closureVoteId: 'v1',
          callerVote: ClosureVoteValue.yes,
          thumbsUp: 3,
          thumbsDown: 1,
          notYetVoted: 0,
        ),
      ),
    );

    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.load();
    await cubit.submitVote(true);

    verify(() => submit(any())).called(1);
    expect(cubit.state.choice, SuccessVoteCastChoice.agreed);
    expect(cubit.state.data?.thumbsUp, 3);
    expect(cubit.state.canVote, isFalse);
    expect(cubit.state.isSubmitting, isFalse);
  });
}
