import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResendCodeUseCase {
  final AuthRepository _repository;

  ResendCodeUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String email,
  }) {
    return _repository.resendCode(email: email);
  }
}
