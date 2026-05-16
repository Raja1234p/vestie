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
  final String? errorMessage;
  final bool joinInProgress;
  final DiscoverJoinEffect? joinEffect;

  const DiscoverState({
    this.allProjects = const [],
    this.filtered = const [],
    this.selectedFilter = AppStrings.filterAll,
    this.searchQuery = '',
    this.loading = false,
    this.errorMessage,
    this.joinInProgress = false,
    this.joinEffect,
  });

  DiscoverState copyWith({
    List<Project>? allProjects,
    List<Project>? filtered,
    String? selectedFilter,
    String? searchQuery,
    bool? loading,
    String? errorMessage,
    bool? joinInProgress,
    DiscoverJoinEffect? joinEffect,
    bool clearErrorMessage = false,
    bool clearJoinEffect = false,
  }) {
    return DiscoverState(
      allProjects: allProjects ?? this.allProjects,
      filtered: filtered ?? this.filtered,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      loading: loading ?? this.loading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      joinInProgress: joinInProgress ?? this.joinInProgress,
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
        errorMessage,
        joinInProgress,
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
  })  : _listProjectsUseCase =
            listProjectsUseCase ?? ServiceLocator.instance.listProjectsUseCase,
        _joinProjectUseCase =
            joinProjectUseCase ?? ServiceLocator.instance.joinProjectUseCase,
        _reloadDiscoverRequested = reloadDiscoverProjectList,
        super(const DiscoverState());

  bool _loadStarted = false;

  void loadIfNeeded() {
    if (_reloadDiscoverRequested && !_consumedShellReload) {
      _consumedShellReload = true;
      _loadStarted = false;
    }
    if (_loadStarted) return;
    _loadStarted = true;
    _load();
  }

  Future<void> _load({bool showLoadingIndicator = true}) async {
    emit(state.copyWith(
      loading: showLoadingIndicator,
      clearErrorMessage: showLoadingIndicator,
    ));
    final result = await _listProjectsUseCase(scope: 'discover');
    result.fold(
      (failure) {
        if (!showLoadingIndicator) {
          emit(state.copyWith(loading: false));
          return;
        }
        emit(state.copyWith(
          loading: false,
          allProjects: const [],
          filtered: const [],
          errorMessage: _userFacingFailureMessage(failure),
        ));
      },
      (projects) {
        final filtered = _applyFilters(
          projects: projects,
          filter: state.selectedFilter,
          searchQuery: state.searchQuery,
        );
        emit(state.copyWith(
          loading: false,
          allProjects: projects,
          filtered: filtered,
          clearErrorMessage: true,
        ));
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
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.categoryLabel.toLowerCase().contains(q))
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
    emit(state.copyWith(
      selectedFilter: filter,
      filtered: _applyFilters(
        projects: state.allProjects,
        filter: filter,
        searchQuery: state.searchQuery,
      ),
    ));
  }

  void search(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filtered: _applyFilters(
        projects: state.allProjects,
        filter: state.selectedFilter,
        searchQuery: query,
      ),
    ));
  }

  Future<void> joinProject(Project project) async {
    if (state.joinInProgress) return;
    emit(state.copyWith(joinInProgress: true, clearJoinEffect: true));

    final result = await _joinProjectUseCase(projectId: project.id);

    result.fold(
      (failure) => emit(state.copyWith(
        joinInProgress: false,
        joinEffect: DiscoverJoinShowError(
          _userFacingFailureMessage(failure),
          title: failure.title,
        ),
      )),
      (joinResult) async {
        if (joinResult.isPendingMembership) {
          emit(state.copyWith(
            joinInProgress: false,
            joinEffect: const DiscoverJoinShowRequestSubmitted(),
          ));
          await refresh(silent: true);
          return;
        }

        final projectId = joinResult.projectId.isNotEmpty
            ? joinResult.projectId
            : project.id;
        emit(state.copyWith(
          joinInProgress: false,
          joinEffect: DiscoverJoinOpenDetail(
            projectId: projectId,
            projectName: project.name,
            isInvestment: project.category.isInvestment,
          ),
        ));
      },
    );
  }

  void clearJoinEffect() {
    if (state.joinEffect == null) return;
    emit(state.copyWith(clearJoinEffect: true));
  }
}
