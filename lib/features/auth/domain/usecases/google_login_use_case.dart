import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GoogleLoginUseCase {
  final AuthRepository _repository;

  GoogleLoginUseCase(this._repository);

  Future<Either<Failure, User>> call() {
    return _repository.loginWithGoogle();
  }
}
