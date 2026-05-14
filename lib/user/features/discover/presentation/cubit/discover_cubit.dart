import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failures.dart';
import '../../../home/domain/entities/project.dart';
import 'package:vestie/features/projects/domain/usecases/list_projects_use_case.dart';

class DiscoverState extends Equatable {
  final List<Project> allProjects;
  final List<Project> filtered;
  final String selectedFilter;
  final String searchQuery;
  final bool loading;
  final String? errorMessage;

  const DiscoverState({
    this.allProjects = const [],
    this.filtered = const [],
    this.selectedFilter = AppStrings.filterAll,
    this.searchQuery = '',
    this.loading = false,
    this.errorMessage,
  });

  DiscoverState copyWith({
    List<Project>? allProjects,
    List<Project>? filtered,
    String? selectedFilter,
    String? searchQuery,
    bool? loading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DiscoverState(
      allProjects: allProjects ?? this.allProjects,
      filtered: filtered ?? this.filtered,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      loading: loading ?? this.loading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [allProjects, filtered, selectedFilter, searchQuery, loading, errorMessage];
}

class DiscoverCubit extends Cubit<DiscoverState> {
  final ListProjectsUseCase _listProjectsUseCase;

  DiscoverCubit({ListProjectsUseCase? listProjectsUseCase})
      : _listProjectsUseCase =
            listProjectsUseCase ?? ServiceLocator.instance.listProjectsUseCase,
        super(const DiscoverState());

  bool _loadStarted = false;

  void loadIfNeeded() {
    if (_loadStarted) return;
    _loadStarted = true;
    _load();
  }

  Future<void> _load() async {
    emit(state.copyWith(loading: true, clearErrorMessage: true));
    final result = await _listProjectsUseCase(scope: 'discover');
    result.fold(
      (failure) => emit(state.copyWith(
        loading: false,
        allProjects: const [],
        filtered: const [],
        errorMessage: _userFacingFailureMessage(failure),
      )),
      (projects) => emit(state.copyWith(
        loading: false,
        allProjects: projects,
        filtered: projects,
        clearErrorMessage: true,
      )),
    );
  }

  String _userFacingFailureMessage(Failure failure) {
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return AppStrings.errorNetwork;
    }
    return failure.message;
  }

  Future<void> refresh() => _load();

  /// Retries after a failed load (same as [refresh]).
  Future<void> retry() => _load();

  void selectFilter(String filter) {
    final projects = state.allProjects;
    final filtered = filter == AppStrings.filterAll
        ? projects
        : projects
            .where((p) => p.categoryLabel == filter)
            .toList();
    emit(state.copyWith(selectedFilter: filter, filtered: filtered));
  }

  void search(String query) {
    final q = query.toLowerCase().trim();
    final filtered = q.isEmpty
        ? state.allProjects
        : state.allProjects
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                p.categoryLabel.toLowerCase().contains(q))
            .toList();
    emit(state.copyWith(searchQuery: query, filtered: filtered));
  }
}
