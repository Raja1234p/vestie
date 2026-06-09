import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import '../entities/borrow_repay_entities.dart';
import '../entities/borrow_terms_entity.dart';
import '../entities/my_borrow_screen_entity.dart';

class BorrowRequestResult {
  final String id;
  final String projectId;
  final double requestedAmount;
  final String currency;
  final String status;
  final String dueAtUtc;

  const BorrowRequestResult({
    required this.id,
    required this.projectId,
    required this.requestedAmount,
    required this.currency,
    required this.status,
    required this.dueAtUtc,
  });
}

class BorrowVoteResult {
  final String borrowRequestId;
  final String callerVote;
  final int upvoteCount;
  final int downvoteCount;

  const BorrowVoteResult({
    required this.borrowRequestId,
    required this.callerVote,
    required this.upvoteCount,
    required this.downvoteCount,
  });
}

abstract class BorrowRepository {
  Future<Either<Failure, BorrowTermsEntity>> getBorrowTerms({
    required String projectId,
    required double amount,
  });

  Future<Either<Failure, List<BorrowRequestEntity>>> listBorrowRequests({
    required String projectId,
    String? status,
  });

  Future<Either<Failure, BorrowVoteResult>> voteBorrowRequest({
    required String projectId,
    required String borrowRequestId,
    required String vote,
  });

  Future<Either<Failure, BorrowRequestResult>> createBorrowRequest({
    required String projectId,
    required double amount,
    required String reason,
    required String idempotencyKey,
  });

  Future<Either<Failure, void>> approveBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  });

  Future<Either<Failure, void>> rejectBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  });

  Future<Either<Failure, MyBorrowScreenEntity>> getMyBorrowScreen({
    required String projectId,
  });

  Future<Either<Failure, void>> cancelBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  });

  Future<Either<Failure, BorrowRepaySummaryEntity?>> getActiveRepaySummary({
    required String projectId,
  });

  Future<Either<Failure, BorrowRepaySummaryEntity>> getBorrowRepaySummary({
    required String projectId,
    required String borrowRequestId,
  });

  Future<Either<Failure, BorrowRepayPaymentOptionsEntity>>
  getBorrowRepayPaymentOptions({
    required String projectId,
    required String borrowRequestId,
  });

  Future<Either<Failure, BorrowRepayPreviewEntity>> getBorrowRepayPreview({
    required String projectId,
    required String borrowRequestId,
    required String paymentSourceType,
    String? paymentMethodId,
  });

  Future<Either<Failure, BorrowRepaymentResultEntity>> submitBorrowRepayment({
    required String projectId,
    required String borrowRequestId,
    required String paymentSourceType,
    String? paymentMethodId,
    required String idempotencyKey,
  });
}
