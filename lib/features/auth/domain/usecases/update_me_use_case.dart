import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/update_me_photo.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateMeUseCase {
  final AuthRepository _repository;

  UpdateMeUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String firstName,
    required String lastName,
    required String userName,
    UpdateMePhoto photo = const UpdateMePhotoUnchanged(),
  }) {
    return _repository.updateMe(
      firstName: firstName,
      lastName: lastName,
      userName: userName,
      photo: photo,
    );
  }
}
