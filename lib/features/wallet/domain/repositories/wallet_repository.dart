import 'package:dartz/dartz.dart';

import 'package:vestie/core/domain/entities/paginated_result.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletEntity>> getWallet({bool forceRefresh = false});

  Future<Either<Failure, PaginatedResult<WalletRecentTransactionEntity>>>
  getTransactions({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });
}
