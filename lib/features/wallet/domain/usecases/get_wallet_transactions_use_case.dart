import 'package:dartz/dartz.dart';

import 'package:vestie/core/domain/entities/paginated_result.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/features/wallet/domain/entities/wallet_entity.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_repository.dart';

class GetWalletTransactionsUseCase {
  final WalletRepository _repository;

  GetWalletTransactionsUseCase(this._repository);

  Future<Either<Failure, PaginatedResult<WalletRecentTransactionEntity>>> call({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) {
    return _repository.getTransactions(page: page, pageSize: pageSize);
  }
}
