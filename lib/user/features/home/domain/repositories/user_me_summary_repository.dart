import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/user_me_summary_entity.dart';

abstract class UserMeSummaryRepository {
  Future<Either<Failure, UserMeSummaryEntity>> getSummary();
}
