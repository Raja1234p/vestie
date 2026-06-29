import '../../models/pagination_dto.dart';
import '../entities/pagination_info.dart';

PaginationInfo paginationInfoFromDto(PaginationDto dto) {
  return PaginationInfo(
    page: dto.page,
    pageSize: dto.pageSize,
    totalCount: dto.totalCount,
    totalPages: dto.totalPages,
  );
}
