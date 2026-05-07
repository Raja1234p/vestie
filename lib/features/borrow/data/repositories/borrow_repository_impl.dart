import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
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
        body: CreateBorrowRequestBody(
          requestedAmount: amount,
          reason: reason,
        ),
      );

      return Right(BorrowRequestResult(
        id: model.id,
        projectId: model.projectId,
        requestedAmount: model.requestedAmount,
        currency: model.currency,
        status: model.status,
        dueAtUtc: model.dueAtUtc,
      ));
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('Borrow Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('Borrow Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Borrow Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('Failed to submit borrow request'));
    }
  }
}

