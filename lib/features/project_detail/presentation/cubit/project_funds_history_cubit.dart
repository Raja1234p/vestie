import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/features/project_detail/domain/entities/project_funds_history_entity.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_project_funds_history_use_case.dart';

class ProjectFundsHistoryState extends Equatable {
  final bool loading;
  final bool loadFailed;
  final bool loadingMore;
  final String? errorMessage;
  final String currency;
  final double currentPotBalance;
  final double totalContribution;
  final double activeBorrows;
  final List<ProjectFundsHistoryEntryEntity> entries;
  final int currentPage;
  final int totalCount;
  final int totalPages;

  const ProjectFundsHistoryState({
    this.loading = false,
    this.loadFailed = false,
    this.loadingMore = false,
    this.errorMessage,
    this.currency = 'USD',
    this.currentPotBalance = 0,
    this.totalContribution = 0,
    this.activeBorrows = 0,
    this.entries = const [],
    this.currentPage = 0,
    this.totalCount = 0,
    this.totalPages = 0,
  });

  bool get hasMore => currentPage < totalPages;

  ProjectFundsHistoryState copyWith({
    bool? loading,
    bool? loadFailed,
    bool? loadingMore,
    String? errorMessage,
    bool clearError = false,
    String? currency,
    double? currentPotBalance,
    double? totalContribution,
    double? activeBorrows,
    List<ProjectFundsHistoryEntryEntity>? entries,
    int? currentPage,
    int? totalCount,
    int? totalPages,
  }) {
    return ProjectFundsHistoryState(
      loading: loading ?? this.loading,
      loadFailed: loadFailed ?? this.loadFailed,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currency: currency ?? this.currency,
      currentPotBalance: currentPotBalance ?? this.currentPotBalance,
      totalContribution: totalContribution ?? this.totalContribution,
      activeBorrows: activeBorrows ?? this.activeBorrows,
      entries: entries ?? this.entries,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    loadFailed,
    loadingMore,
    errorMessage,
    currency,
    currentPotBalance,
    totalContribution,
    activeBorrows,
    entries,
    currentPage,
    totalCount,
    totalPages,
  ];
}

/// Loads `GET /projects/{projectId}/funds-history` for [ProjectFundsHistoryScreen].
class ProjectFundsHistoryCubit extends Cubit<ProjectFundsHistoryState> {
  final String projectId;
  final GetProjectFundsHistoryUseCase _getFundsHistory;

  ProjectFundsHistoryCubit({
    required this.projectId,
    required GetProjectFundsHistoryUseCase getFundsHistoryUseCase,
  }) : _getFundsHistory = getFundsHistoryUseCase,
       super(const ProjectFundsHistoryState(loading: true)) {
    load();
  }

  Future<void> load() async {
    emit(
      state.copyWith(
        loading: true,
        loadingMore: false,
        loadFailed: false,
        clearError: true,
      ),
    );
    final result = await _getFundsHistory(
      projectId,
      page: PaginationQuery.defaultPage,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          loading: false,
          loadFailed: true,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (entity) => emit(
        ProjectFundsHistoryState(
          loading: false,
          currency: entity.currency,
          currentPotBalance: entity.currentPotBalance,
          totalContribution: entity.totalContribution,
          activeBorrows: entity.activeBorrows,
          entries: entity.entries,
          currentPage: entity.pagination.page,
          totalCount: entity.pagination.totalCount,
          totalPages: entity.pagination.totalPages,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;

    emit(state.copyWith(loadingMore: true, clearError: true));
    final nextPage = state.currentPage + 1;
    final result = await _getFundsHistory(projectId, page: nextPage);
    result.fold(
      (failure) => emit(
        state.copyWith(
          loadingMore: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (entity) => emit(
        state.copyWith(
          entries: [...state.entries, ...entity.entries],
          loadingMore: false,
          currentPage: entity.pagination.page,
          totalCount: entity.pagination.totalCount,
          totalPages: entity.pagination.totalPages,
          clearError: true,
        ),
      ),
    );
  }
}
