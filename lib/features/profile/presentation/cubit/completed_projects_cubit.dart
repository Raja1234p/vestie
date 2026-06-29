import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/domain/entities/paginated_result.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/features/projects/domain/usecases/list_projects_use_case.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/mock_projects.dart';

class CompletedProjectsState extends Equatable {
  final List<Project> projects;
  final bool loading;
  final bool loadingMore;
  final int currentPage;
  final int totalCount;
  final String? errorMessage;

  const CompletedProjectsState({
    this.projects = const [],
    this.loading = false,
    this.loadingMore = false,
    this.currentPage = 0,
    this.totalCount = 0,
    this.errorMessage,
  });

  bool get hasMore => projects.length < totalCount;

  CompletedProjectsState copyWith({
    List<Project>? projects,
    bool? loading,
    bool? loadingMore,
    int? currentPage,
    int? totalCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CompletedProjectsState(
      projects: projects ?? this.projects,
      loading: loading ?? this.loading,
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
    loadingMore,
    currentPage,
    totalCount,
    errorMessage,
  ];
}

class CompletedProjectsCubit extends Cubit<CompletedProjectsState> {
  /// Set `false` when API-backed list is ready for production.
  static const bool previewDemoWhenEmpty = true;

  CompletedProjectsCubit({ListProjectsUseCase? listProjectsUseCase})
    : _listProjectsUseCase =
          listProjectsUseCase ?? ServiceLocator.instance.listProjectsUseCase,
      super(const CompletedProjectsState(loading: true)) {
    load();
  }

  final ListProjectsUseCase _listProjectsUseCase;
  List<Project> _allMineProjects = const [];

  Future<void> load() async {
    emit(
      state.copyWith(
        loading: true,
        loadingMore: false,
        clearError: true,
      ),
    );
    final result = await _listProjectsUseCase(scope: 'mine', page: 1);
    result.fold(
      (failure) =>
          emit(state.copyWith(loading: false, errorMessage: failure.message)),
      (page) {
        _allMineProjects = page.items;
        emit(
          _stateFromMinePage(
            page,
            replaceProjects: true,
            loading: false,
          ),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;

    emit(state.copyWith(loadingMore: true, clearError: true));
    final nextPage = state.currentPage + 1;
    final result = await _listProjectsUseCase(
      scope: 'mine',
      page: nextPage,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(loadingMore: false, errorMessage: failure.message),
      ),
      (page) {
        _allMineProjects = [..._allMineProjects, ...page.items];
        emit(
          _stateFromMinePage(
            page,
            replaceProjects: false,
            loading: false,
            loadingMore: false,
          ),
        );
      },
    );
  }

  CompletedProjectsState _stateFromMinePage(
    PaginatedResult<Project> page, {
    required bool replaceProjects,
    required bool loading,
    bool loadingMore = false,
  }) {
    var completed = _allMineProjects
        .where((p) => p.status == ProjectStatus.completed)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    if (completed.isEmpty &&
        previewDemoWhenEmpty &&
        page.page == PaginationQuery.defaultPage) {
      completed = List<Project>.of(MockProjects.previewCompletedProjects)
        ..sort((a, b) => a.name.compareTo(b.name));
    }
    return CompletedProjectsState(
      projects: completed,
      loading: loading,
      loadingMore: loadingMore,
      currentPage: page.page,
      totalCount: page.totalCount,
    );
  }
}
