import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletEntity>> getWallet({bool forceRefresh = false});
}
