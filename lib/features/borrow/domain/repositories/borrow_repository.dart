import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

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

abstract class BorrowRepository {
  Future<Either<Failure, BorrowRequestResult>> createBorrowRequest({
    required String projectId,
    required double amount,
    required String reason,
  });

  Future<Either<Failure, void>> approveBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  });

  Future<Either<Failure, void>> rejectBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  });
}

