import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/account_repository.dart';

class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository);

  final AccountRepository _repository;

  Future<Either<Failure, void>> call({bool confirmed = true}) =>
      _repository.deleteAccount(confirmed: confirmed);
}
