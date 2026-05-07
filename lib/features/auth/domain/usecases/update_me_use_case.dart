import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateMeUseCase {
  final AuthRepository _repository;

  UpdateMeUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String firstName,
    required String lastName,
    required String userName,
    required String photoUrl,
  }) {
    return _repository.updateMe(
      firstName: firstName,
      lastName: lastName,
      userName: userName,
      photoUrl: photoUrl,
    );
  }
}

