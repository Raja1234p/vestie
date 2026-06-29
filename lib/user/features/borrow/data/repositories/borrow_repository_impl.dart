import 'package:dartz/dartz.dart';

import 'package:vestie/core/domain/entities/paginated_result.dart';
import 'package:vestie/core/domain/mappers/pagination_mapper.dart';
import 'package:vestie/core/error/exceptions.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/core/utils/logger.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import '../../domain/entities/borrow_repay_entities.dart';
import '../../domain/entities/borrow_terms_entity.dart';
import '../../domain/entities/my_borrow_screen_entity.dart';
import '../mappers/borrow_repay_mapper.dart';
import '../models/my_borrow_screen_model.dart';
import '../../domain/repositories/borrow_repository.dart';
import '../datasources/borrow_remote_data_source.dart';

class BorrowRepositoryImpl implements BorrowRepository {
  final BorrowRemoteDataSource _remote;

  BorrowRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, BorrowTermsEntity>> getBorrowTerms({
    required String projectId,
    required double amount,
  }) async {
    try {
      final model = await _remote.getBorrowTerms(
        projectId: projectId,
        amount: amount,
      );
      return Right(
        BorrowTermsEntity(
          amount: model.amount,
          currency: model.currency,
          dueByDisplay: model.dueByDisplay,
          penaltyPercentage: model.penaltyPercentage,
          penaltyIfMissedDisplay: model.penaltyIfMissedDisplay,
          penaltyAppliesDisplay: model.penaltyAppliesDisplay,
          agreementText: model.agreementText,
          canBorrow: model.canBorrow,
        ),
      );
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('GetBorrowTerms Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('GetBorrowTerms Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'GetBorrowTerms Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to load borrow terms'));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<BorrowRequestEntity>>> listBorrowRequests({
    required String projectId,
    String? status,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    try {
      final pageModel = await _remote.listBorrowRequests(
        projectId: projectId,
        status: status,
        page: page,
        pageSize: pageSize,
      );
      return Right(
        PaginatedResult.fromPaginatedList(
          PaginatedListModel(
            items: pageModel.items.map((item) => item.toEntity()).toList(),
            pagination: pageModel.pagination,
          ),
        ),
      );
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('ListBorrowRequests Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('ListBorrowRequests Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'ListBorrowRequests Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to load borrow requests'));
    }
  }

  @override
  Future<Either<Failure, BorrowVoteResult>> voteBorrowRequest({
    required String projectId,
    required String borrowRequestId,
    required String vote,
  }) async {
    try {
      final model = await _remote.voteBorrowRequest(
        projectId: projectId,
        borrowRequestId: borrowRequestId,
        vote: vote,
      );
      return Right(
        BorrowVoteResult(
          borrowRequestId: model.borrowRequestId,
          callerVote: model.callerVote,
          upvoteCount: model.upvoteCount,
          downvoteCount: model.downvoteCount,
        ),
      );
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('VoteBorrowRequest Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('VoteBorrowRequest Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'VoteBorrowRequest Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to submit vote'));
    }
  }

  @override
  Future<Either<Failure, BorrowRequestResult>> createBorrowRequest({
    required String projectId,
    required double amount,
    required String reason,
    required String idempotencyKey,
  }) async {
    try {
      final model = await _remote.createBorrowRequest(
        projectId: projectId,
        body: CreateBorrowRequestBody(requestedAmount: amount, reason: reason),
        idempotencyKey: idempotencyKey,
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
  }) {
    return _decide(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
      decision: 'Approve',
      logLabel: 'ApproveBorrowRequest',
      fallbackMessage: 'Failed to approve borrow request',
    );
  }

  @override
  Future<Either<Failure, void>> rejectBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  }) {
    return _decide(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
      decision: 'Reject',
      logLabel: 'RejectBorrowRequest',
      fallbackMessage: 'Failed to reject borrow request',
    );
  }

  @override
  Future<Either<Failure, MyBorrowScreenEntity>> getMyBorrowScreen({
    required String projectId,
    int historyPage = PaginationQuery.defaultPage,
    int? historyPageSize,
  }) async {
    try {
      final model = await _remote.getMyBorrowScreen(
        projectId: projectId,
        historyPage: historyPage,
        historyPageSize: historyPageSize,
      );
      final mapped = _mapMyBorrowScreen(model);
      final active = mapped.activeRequest;
      if (active != null && active.isPending) {
        return Right(mapped);
      }

      final mine = await _remote.listMyBorrowRequests(projectId: projectId);
      return Right(_mergeMyBorrowScreen(model, mine.items));
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('GetMyBorrowScreen Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('GetMyBorrowScreen Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'GetMyBorrowScreen Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to load borrow request'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  }) async {
    try {
      await _remote.cancelBorrowRequest(
        projectId: projectId,
        borrowRequestId: borrowRequestId,
      );
      return const Right(null);
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('CancelBorrowRequest Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('CancelBorrowRequest Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'CancelBorrowRequest Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to cancel borrow request'));
    }
  }

  @override
  Future<Either<Failure, BorrowRepaySummaryEntity?>> getActiveRepaySummary({
    required String projectId,
  }) async {
    try {
      final mine = await _remote.listMyBorrowRequests(projectId: projectId);
      final repayable = mine.items
          .map((item) => item.toEntity())
          .where((item) => item.isRepayableBorrow)
          .toList();
      if (repayable.isEmpty) return const Right(null);

      final model = await _remote.getBorrowRepaySummary(
        projectId: projectId,
        borrowRequestId: repayable.first.id,
      );
      final entity = BorrowRepayMapper.toSummaryEntity(model);
      if (!entity.canRepay) return const Right(null);
      return Right(entity);
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('GetActiveRepaySummary Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('GetActiveRepaySummary Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'GetActiveRepaySummary Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to load borrow repayment'));
    }
  }

  @override
  Future<Either<Failure, BorrowRepaySummaryEntity>> getBorrowRepaySummary({
    required String projectId,
    required String borrowRequestId,
  }) {
    return _repayCall(
      () async {
        final model = await _remote.getBorrowRepaySummary(
          projectId: projectId,
          borrowRequestId: borrowRequestId,
        );
        return BorrowRepayMapper.toSummaryEntity(model);
      },
      logLabel: 'GetBorrowRepaySummary',
      fallbackMessage: 'Failed to load borrow repayment',
    );
  }

  @override
  Future<Either<Failure, BorrowRepayPaymentOptionsEntity>>
  getBorrowRepayPaymentOptions({
    required String projectId,
    required String borrowRequestId,
  }) {
    return _repayCall(
      () async {
        final model = await _remote.getBorrowRepayPaymentOptions(
          projectId: projectId,
          borrowRequestId: borrowRequestId,
        );
        return BorrowRepayMapper.toPaymentOptionsEntity(model);
      },
      logLabel: 'GetBorrowRepayPaymentOptions',
      fallbackMessage: 'Failed to load payment options',
    );
  }

  @override
  Future<Either<Failure, BorrowRepayPreviewEntity>> getBorrowRepayPreview({
    required String projectId,
    required String borrowRequestId,
    required String paymentSourceType,
    String? paymentMethodId,
  }) {
    return _repayCall(
      () async {
        final model = await _remote.getBorrowRepayPreview(
          projectId: projectId,
          borrowRequestId: borrowRequestId,
          paymentSourceType: paymentSourceType,
          paymentMethodId: paymentMethodId,
        );
        return BorrowRepayMapper.toPreviewEntity(model);
      },
      logLabel: 'GetBorrowRepayPreview',
      fallbackMessage: 'Failed to load repayment preview',
    );
  }

  @override
  Future<Either<Failure, BorrowRepaymentResultEntity>> submitBorrowRepayment({
    required String projectId,
    required String borrowRequestId,
    required String paymentSourceType,
    String? paymentMethodId,
    required String idempotencyKey,
  }) {
    return _repayCall(
      () async {
        final model = await _remote.submitBorrowRepayment(
          projectId: projectId,
          borrowRequestId: borrowRequestId,
          paymentSourceType: paymentSourceType,
          paymentMethodId: paymentMethodId,
          idempotencyKey: idempotencyKey,
        );
        return BorrowRepayMapper.toResultEntity(model);
      },
      logLabel: 'SubmitBorrowRepayment',
      fallbackMessage: 'Failed to submit repayment',
    );
  }

  Future<Either<Failure, T>> _repayCall<T>(
    Future<T> Function() call, {
    required String logLabel,
    required String fallbackMessage,
  }) async {
    try {
      return Right(await call());
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('$logLabel Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('$logLabel Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        '$logLabel Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(fallbackMessage));
    }
  }

  MyBorrowScreenEntity _mapMyBorrowScreen(MyBorrowScreenModel model) {
    return MyBorrowScreenEntity(
      activeRequest: model.currentRequest?.toEntity(),
      history: model.history.map((h) => h.toHistoryEntry()).toList(growable: false),
      historyPagination: paginationInfoFromDto(model.historyPagination),
    );
  }

  /// When `mine/screen` omits `currentRequest`, resolve pending row from `GET …/mine`.
  MyBorrowScreenEntity _mergeMyBorrowScreen(
    MyBorrowScreenModel screen,
    List<MyBorrowCurrentRequestModel> mine,
  ) {
    BorrowRequestEntity? active = screen.currentRequest?.toEntity();
    if (active == null || !active.isPending) {
      for (final item in mine) {
        final entity = item.toEntity();
        if (entity.isPending) {
          active = entity;
          break;
        }
      }
    }

    var history =
        screen.history.map((h) => h.toHistoryEntry()).toList(growable: false);
    if (history.isEmpty && mine.isNotEmpty) {
      history = [
        for (final item in mine)
          if (!item.toEntity().isPending) item.toHistoryEntry(),
      ];
    }

    return MyBorrowScreenEntity(
      activeRequest: active,
      history: history,
      historyPagination: paginationInfoFromDto(screen.historyPagination),
    );
  }

  Future<Either<Failure, void>> _decide({
    required String projectId,
    required String borrowRequestId,
    required String decision,
    required String logLabel,
    required String fallbackMessage,
  }) async {
    try {
      await _remote.decideBorrowRequest(
        projectId: projectId,
        borrowRequestId: borrowRequestId,
        decision: decision,
      );
      return const Right(null);
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('$logLabel Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('$logLabel Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        '$logLabel Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(fallbackMessage));
    }
  }
}
