import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/project_detail/presentation/cubit/borrow_vote_cubit.dart';
import 'package:vestie/user/features/borrow/domain/repositories/borrow_repository.dart';
import 'package:vestie/user/features/borrow/domain/usecases/vote_borrow_request_use_case.dart';

class _MockVoteBorrowRequestUseCase extends Mock
    implements VoteBorrowRequestUseCase {}

void main() {
  late _MockVoteBorrowRequestUseCase voteUseCase;

  setUp(() {
    voteUseCase = _MockVoteBorrowRequestUseCase();
  });

  BorrowVoteCubit createCubit() => BorrowVoteCubit(
    voteUseCase: voteUseCase,
    projectId: 'proj-1',
    requestId: 'req-1',
    upvotes: 2,
    downvotes: 1,
  );

  group('BorrowVoteCubit', () {
    test('voteAgree updates counts on success', () async {
      when(
        () => voteUseCase(
          projectId: any(named: 'projectId'),
          borrowRequestId: any(named: 'borrowRequestId'),
          vote: any(named: 'vote'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          BorrowVoteResult(
            borrowRequestId: 'req-1',
            callerVote: 'Agree',
            upvoteCount: 3,
            downvoteCount: 1,
          ),
        ),
      );

      final cubit = createCubit();
      addTearDown(cubit.close);

      final error = await cubit.voteAgree();

      expect(error, isNull);
      expect(cubit.state.hasUpvoted, isTrue);
      expect(cubit.state.upvotes, 3);
      expect(cubit.state.isVoting, isFalse);
    });

    test('voteAgree returns mapped message on failure', () async {
      when(
        () => voteUseCase(
          projectId: any(named: 'projectId'),
          borrowRequestId: any(named: 'borrowRequestId'),
          vote: any(named: 'vote'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Vote failed')));

      final cubit = createCubit();
      addTearDown(cubit.close);

      final error = await cubit.voteAgree();

      expect(error, 'Vote failed');
      expect(cubit.state.upvotes, 2);
      expect(cubit.state.isVoting, isFalse);
    });
  });
}
