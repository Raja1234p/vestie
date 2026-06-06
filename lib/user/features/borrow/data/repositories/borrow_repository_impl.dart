import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/exceptions.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/utils/logger.dart';
import '../../domain/repositories/borrow_repository.dart';
import '../datasources/borrow_remote_data_source.dart';

class BorrowRepositoryImpl implements BorrowRepository {
  final BorrowRemoteDataSource _remote;

  BorrowRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, BorrowRequestResult>> createBorrowRequest({
    required String projectId,
    required double amount,
    required String reason,
  }) async {
    try {
      final model = await _remote.createBorrowRequest(
        projectId: projectId,
        body: CreateBorrowRequestBody(requestedAmount: amount, reason: reason),
      );

      return Right(
        BorrowRequestResult(
          id: model.id,
          projectId: model.projectId,
          requestedAmount: model.requestedAmount,
          currency: model.currency,
          status: model.status,
          dueAtUtc: model.dueAtUtc,
        ),
      );
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('Borrow Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('Borrow Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Borrow Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to submit borrow request'));
    }
  }

  @override
  Future<Either<Failure, void>> approveBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  }) async {
    try {
      await _remote.approveBorrowRequest(
        projectId: projectId,
        borrowRequestId: borrowRequestId,
      );
      return const Right(null);
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error(
        'ApproveBorrowRequest Unauthorized',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'ApproveBorrowRequest Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'ApproveBorrowRequest Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to approve borrow request'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  }) async {
    try {
      await _remote.rejectBorrowRequest(
        projectId: projectId,
        borrowRequestId: borrowRequestId,
      );
      return const Right(null);
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error(
        'RejectBorrowRequest Unauthorized',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'RejectBorrowRequest Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'RejectBorrowRequest Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to reject borrow request'));
    }
  }
}
