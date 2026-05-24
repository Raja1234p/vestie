import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/user_me_summary_entity.dart';
import '../repositories/user_me_summary_repository.dart';

class GetUserMeSummaryUseCase {
  final UserMeSummaryRepository _repository;

  GetUserMeSummaryUseCase(this._repository);

  Future<Either<Failure, UserMeSummaryEntity>> call() {
    return _repository.getSummary();
  }
}
