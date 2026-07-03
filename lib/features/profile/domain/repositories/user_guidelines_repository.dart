import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_guidelines_page.dart';

abstract class UserGuidelinesRepository {
  Future<Either<Failure, UserGuidelinesPage>> getUserGuidelines();
}
