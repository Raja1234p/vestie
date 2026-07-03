import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/features/projects/domain/usecases/list_completed_projects_use_case.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

class CompletedProjectsState extends Equatable {
  final List<Project> projects;
  final bool loading;
  final bool loadFailed;
  final bool loadingMore;
  final int currentPage;
  final int totalCount;
  final String? errorMessage;

  const CompletedProjectsState({
    this.projects = const [],
    this.loading = false,
    this.loadFailed = false,
    this.loadingMore = false,
    this.currentPage = 0,
    this.totalCount = 0,
    this.errorMessage,
  });

  bool get hasMore => projects.length < totalCount;

  CompletedProjectsState copyWith({
    List<Project>? projects,
    bool? loading,
    bool? loadFailed,
    bool? loadingMore,
    int? currentPage,
    int? totalCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CompletedProjectsState(
      projects: projects ?? this.projects,
      loading: loading ?? this.loading,
      loadFailed: loadFailed ?? this.loadFailed,
      loadingMore: loadingMore ?? this.loadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    projects,
    loading,
    loadFailed,
    loadingMore,
    currentPage,
    totalCount,
    errorMessage,
  ];
}

class CompletedProjectsCubit extends Cubit<CompletedProjectsState> {
  CompletedProjectsCubit({ListCompletedProjectsUseCase? listCompletedProjects})
    : _listCompletedProjects =
          listCompletedProjects ??
          ServiceLocator.instance.listCompletedProjectsUseCase,
      super(const CompletedProjectsState(loading: true)) {
    load();
  }

  final ListCompletedProjectsUseCase _listCompletedProjects;

  Future<void> load() async {
    emit(
      state.copyWith(
        loading: true,
        loadingMore: false,
        loadFailed: false,
        clearError: true,
      ),
    );
    final result = await _listCompletedProjects(page: PaginationQuery.defaultPage);
    result.fold(
      (failure) => emit(
        state.copyWith(
          loading: false,
          loadFailed: true,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (page) => emit(
        state.copyWith(
          projects: page.items,
          loading: false,
          loadFailed: false,
          currentPage: page.page,
          totalCount: page.totalCount,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;

    emit(state.copyWith(loadingMore: true, clearError: true));
    final nextPage = state.currentPage + 1;
    final result = await _listCompletedProjects(page: nextPage);
    result.fold(
      (failure) => emit(
        state.copyWith(
          loadingMore: false,
          loadFailed: true,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (page) => emit(
        state.copyWith(
          projects: [...state.projects, ...page.items],
          loadingMore: false,
          loadFailed: false,
          currentPage: page.page,
          totalCount: page.totalCount,
          clearError: true,
        ),
      ),
    );
  }
}
