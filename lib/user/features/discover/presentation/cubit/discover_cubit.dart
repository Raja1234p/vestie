import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failures.dart';
import '../../../home/domain/entities/project.dart';
import '../../../home/domain/entities/project_category_extensions.dart';
import 'package:vestie/features/projects/domain/usecases/join_project_usecase.dart';
import 'package:vestie/features/projects/domain/usecases/list_projects_use_case.dart';

import 'discover_join_effect.dart';

class DiscoverState extends Equatable {
  final List<Project> allProjects;
  final List<Project> filtered;
  final String selectedFilter;
  final String searchQuery;
  final bool loading;
  final bool loadingMore;
  final int currentPage;
  final int totalCount;
  final String? errorMessage;

  /// Project id while join / request-to-join API is in flight (button spinner).
  final String? joiningProjectId;
  final DiscoverJoinEffect? joinEffect;

  const DiscoverState({
    this.allProjects = const [],
    this.filtered = const [],
    this.selectedFilter = AppStrings.filterAll,
    this.searchQuery = '',
    this.loading = false,
    this.loadingMore = false,
    this.currentPage = 0,
    this.totalCount = 0,
    this.errorMessage,
    this.joiningProjectId,
    this.joinEffect,
  });

  bool get hasMore => allProjects.length < totalCount;

  DiscoverState copyWith({
    List<Project>? allProjects,
    List<Project>? filtered,
    String? selectedFilter,
    String? searchQuery,
    bool? loading,
    bool? loadingMore,
    int? currentPage,
    int? totalCount,
    String? errorMessage,
    String? joiningProjectId,
    DiscoverJoinEffect? joinEffect,
    bool clearErrorMessage = false,
    bool clearJoinEffect = false,
    bool clearJoiningProjectId = false,
  }) {
    return DiscoverState(
      allProjects: allProjects ?? this.allProjects,
      filtered: filtered ?? this.filtered,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      joiningProjectId: clearJoiningProjectId
          ? null
          : (joiningProjectId ?? this.joiningProjectId),
      joinEffect: clearJoinEffect ? null : (joinEffect ?? this.joinEffect),
    );
  }

  @override
  List<Object?> get props => [
    allProjects,
    filtered,
    selectedFilter,
    searchQuery,
    loading,
    loadingMore,
    currentPage,
    totalCount,
    errorMessage,
    joiningProjectId,
    joinEffect,
  ];
}

class DiscoverCubit extends Cubit<DiscoverState> {
  final ListProjectsUseCase _listProjectsUseCase;
  final JoinProjectUseCase _joinProjectUseCase;
  final bool _reloadDiscoverRequested;
  bool _consumedShellReload = false;

  DiscoverCubit({
    ListProjectsUseCase? listProjectsUseCase,
    JoinProjectUseCase? joinProjectUseCase,
    bool reloadDiscoverProjectList = false,
  }) : _listProjectsUseCase =
           listProjectsUseCase ?? ServiceLocator.instance.listProjectsUseCase,
       _joinProjectUseCase =
           joinProjectUseCase ?? ServiceLocator.instance.joinProjectUseCase,
       _reloadDiscoverRequested = reloadDiscoverProjectList,
       super(const DiscoverState());

  bool _loadStarted = false;

  /// Loads on first visit; refetches when the Discover tab is selected again.
  void onTabActivated() {
    if (_reloadDiscoverRequested && !_consumedShellReload) {
      _consumedShellReload = true;
      _loadStarted = false;
    }
    if (!_loadStarted) {
      _loadStarted = true;
      _load();
      return;
    }
    if (state.loading) return;
    refresh(silent: state.allProjects.isNotEmpty);
  }

  Future<void> _load({bool showLoadingIndicator = true}) async {
    emit(
      state.copyWith(
        loading: showLoadingIndicator,
        loadingMore: false,
        clearErrorMessage: showLoadingIndicator,
      ),
    );
    final result = await _listProjectsUseCase(scope: 'discover', page: 1);
    result.fold(
      (failure) {
        if (!showLoadingIndicator) {
          emit(state.copyWith(loading: false));
          return;
        }
        emit(
          state.copyWith(
            loading: false,
            allProjects: const [],
            filtered: const [],
            errorMessage: _userFacingFailureMessage(failure),
          ),
        );
      },
      (page) {
        final filtered = _applyFilters(
          projects: page.items,
          filter: state.selectedFilter,
          searchQuery: state.searchQuery,
        );
        emit(
          state.copyWith(
            loading: false,
            allProjects: page.items,
            filtered: filtered,
            currentPage: page.page,
            totalCount: page.totalCount,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.loading ||
        state.loadingMore ||
        !state.hasMore ||
        state.searchQuery.isNotEmpty) {
      return;
    }

    emit(state.copyWith(loadingMore: true, clearErrorMessage: true));
    final nextPage = state.currentPage + 1;
    final result = await _listProjectsUseCase(
      scope: 'discover',
      page: nextPage,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          loadingMore: false,
          errorMessage: _userFacingFailureMessage(failure),
        ),
      ),
      (page) {
        final allProjects = [...state.allProjects, ...page.items];
        emit(
          state.copyWith(
            allProjects: allProjects,
            filtered: _applyFilters(
              projects: allProjects,
              filter: state.selectedFilter,
              searchQuery: state.searchQuery,
            ),
            currentPage: page.page,
            totalCount: page.totalCount,
            loadingMore: false,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  List<Project> _applyFilters({
    required List<Project> projects,
    required String filter,
    required String searchQuery,
  }) {
    var list = filter == AppStrings.filterAll
        ? projects
        : projects.where((p) => p.categoryLabel == filter).toList();
    final q = searchQuery.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.categoryLabel.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  String _userFacingFailureMessage(Failure failure) {
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return AppStrings.errorNetwork;
    }
    return failure.message;
  }

  /// [silent] refreshes in the background without the full-list shimmer.
  Future<void> refresh({bool silent = false}) =>
      _load(showLoadingIndicator: !silent);

  /// Retries after a failed load (same as [refresh]).
  Future<void> retry() => _load();

  void selectFilter(String filter) {
    emit(
      state.copyWith(
        selectedFilter: filter,
        filtered: _applyFilters(
          projects: state.allProjects,
          filter: filter,
          searchQuery: state.searchQuery,
        ),
      ),
    );
  }

  void search(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        filtered: _applyFilters(
          projects: state.allProjects,
          filter: state.selectedFilter,
          searchQuery: query,
        ),
      ),
    );
  }

  /// Clears discover search and restores the list for the active filter.
  void clearSearch() {
    if (state.searchQuery.isEmpty) return;
    search('');
  }

  /// Discover tab hidden — drop stale search so returning shows the full list.
  void onTabDeactivated() {
    clearSearch();
  }

  Future<void> joinProject(Project project) async {
    if (state.joiningProjectId != null) return;
    emit(state.copyWith(joiningProjectId: project.id, clearJoinEffect: true));

    final result = await _joinProjectUseCase(projectId: project.id);

    result.fold(
      (failure) => emit(
        state.copyWith(
          clearJoiningProjectId: true,
          joinEffect: DiscoverJoinShowError(
            _userFacingFailureMessage(failure),
            title: failure.title,
          ),
        ),
      ),
      (joinResult) async {
        if (joinResult.isPendingMembership) {
          final projectId = joinResult.projectId.isNotEmpty
              ? joinResult.projectId
              : project.id;
          emit(
            state.copyWith(
              clearJoiningProjectId: true,
              joinEffect: DiscoverJoinShowRequestSubmitted(
                projectId: projectId,
                projectName: project.name,
                isInvestment: project.category.isInvestment,
              ),
            ),
          );
          await refresh(silent: true);
          return;
        }

        final projectId = joinResult.projectId.isNotEmpty
            ? joinResult.projectId
            : project.id;
        emit(
          state.copyWith(
            clearJoiningProjectId: true,
            joinEffect: DiscoverJoinOpenDetail(
              projectId: projectId,
              projectName: project.name,
              isInvestment: project.category.isInvestment,
            ),
          ),
        );
      },
    );
  }

  void clearJoinEffect() {
    if (state.joinEffect == null) return;
    emit(state.copyWith(clearJoinEffect: true));
  }
}
