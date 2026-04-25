import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String code,
  }) {
    return _repository.verifyEmail(email: email, code: code);
  }
}
