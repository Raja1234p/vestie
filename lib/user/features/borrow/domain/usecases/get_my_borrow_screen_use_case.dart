import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import '../entities/my_borrow_screen_entity.dart';
import '../repositories/borrow_repository.dart';

class GetMyBorrowScreenUseCase {
  final BorrowRepository _repository;

  GetMyBorrowScreenUseCase(this._repository);

  Future<Either<Failure, MyBorrowScreenEntity>> call({
    required String projectId,
    int historyPage = PaginationQuery.defaultPage,
    int? historyPageSize,
  }) {
    return _repository.getMyBorrowScreen(
      projectId: projectId,
      historyPage: historyPage,
      historyPageSize: historyPageSize,
    );
  }
}
