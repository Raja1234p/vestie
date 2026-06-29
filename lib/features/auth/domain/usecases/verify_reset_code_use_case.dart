import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/verify_reset_code_result.dart';
import '../repositories/auth_repository.dart';

class VerifyResetCodeUseCase {
  final AuthRepository _repository;

  VerifyResetCodeUseCase(this._repository);

  Future<Either<Failure, VerifyResetCodeResult>> call({
    required String email,
    required String code,
  }) {
    return _repository.verifyResetCode(email: email, code: code);
  }
}
