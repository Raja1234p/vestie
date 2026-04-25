import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _repository.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}
