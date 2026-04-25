import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String refreshToken,
  }) {
    return _repository.logout(refreshToken: refreshToken);
  }
}
