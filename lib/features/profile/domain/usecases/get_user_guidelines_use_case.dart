import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_guidelines_page.dart';
import '../repositories/user_guidelines_repository.dart';

class GetUserGuidelinesUseCase {
  GetUserGuidelinesUseCase(this._repository);

  final UserGuidelinesRepository _repository;

  Future<Either<Failure, UserGuidelinesPage>> call() {
    return _repository.getUserGuidelines();
  }
}
