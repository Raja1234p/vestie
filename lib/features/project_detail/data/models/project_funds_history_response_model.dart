import '../../../../core/domain/entities/pagination_info.dart';
import '../../../../core/models/pagination_dto.dart';
import '../../../../core/utils/safe_parser.dart';
import '../../domain/entities/project_funds_history_entity.dart';

/// `GET /projects/{projectId}/funds-history` response.
class ProjectFundsHistoryResponseModel {
  final String projectId;
  final String currency;
  final double currentPotBalance;
  final double totalContribution;
  final double activeBorrows;
  final List<ProjectFundsHistoryEntryModel> entries;
  final PaginationDto pagination;

  const ProjectFundsHistoryResponseModel({
    required this.projectId,
    required this.currency,
    required this.currentPotBalance,
    required this.totalContribution,
    required this.activeBorrows,
    required this.entries,
    required this.pagination,
  });

  factory ProjectFundsHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final historyParsed = PaginatedListParser.parse(
      json.safeMap('history'),
      ProjectFundsHistoryEntryModel.fromJson,
    );
    return ProjectFundsHistoryResponseModel(
      projectId: json.safeString('projectId'),
      currency: json.safeString('currency', defaultValue: 'USD'),
      currentPotBalance: json.safeDouble('currentPotBalance'),
      totalContribution: json.safeDouble('totalContribution'),
      activeBorrows: json.safeDouble('activeBorrows'),
      entries: historyParsed.items,
      pagination: historyParsed.pagination,
    );
  }

  ProjectFundsHistoryEntity toEntity() {
    return ProjectFundsHistoryEntity(
      projectId: projectId,
      currency: currency,
      currentPotBalance: currentPotBalance,
      totalContribution: totalContribution,
      activeBorrows: activeBorrows,
      entries: entries.map((e) => e.toEntity()).toList(growable: false),
      pagination: PaginationInfo(
        page: pagination.page,
        pageSize: pagination.pageSize,
        totalCount: pagination.totalCount,
        totalPages: pagination.totalPages,
      ),
    );
  }
}

class ProjectFundsHistoryEntryModel {
  final String id;
  final String name;
  final String type;
  final double amount;
  final String direction;
  final DateTime? date;

  const ProjectFundsHistoryEntryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.direction,
    this.date,
  });

  factory ProjectFundsHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return ProjectFundsHistoryEntryModel(
      id: json.safeString('id'),
      name: json.safeString('name'),
      type: json.safeString('type'),
      amount: json.safeDouble('amount'),
      direction: json.safeString('direction'),
      date: json.safeDateTimeUtc('date'),
    );
  }

  ProjectFundsHistoryEntryEntity toEntity() {
    return ProjectFundsHistoryEntryEntity(
      id: id,
      name: name,
      type: type,
      amount: amount,
      direction: direction,
      date: date,
    );
  }
}
