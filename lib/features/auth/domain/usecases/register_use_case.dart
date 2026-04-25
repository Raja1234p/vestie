import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/register_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, RegisterResult>> call({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _repository.register(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
