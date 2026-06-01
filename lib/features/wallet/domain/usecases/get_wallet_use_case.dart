import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository repository;

  GetWalletUseCase(this.repository);

  Future<Either<Failure, WalletEntity>> call({bool forceRefresh = false}) =>
      repository.getWallet(forceRefresh: forceRefresh);
}
