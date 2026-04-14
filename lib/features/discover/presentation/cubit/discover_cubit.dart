import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../home/domain/entities/project.dart';
import '../../../home/domain/mock_projects.dart';

class DiscoverState extends Equatable {
  final List<Project> allProjects;
  final List<Project> filtered;
  final String selectedFilter;
  final String searchQuery;
  final bool loading;

  const DiscoverState({
    this.allProjects = const [],
    this.filtered = const [],
    this.selectedFilter = AppStrings.filterAll,
    this.searchQuery = '',
    this.loading = false,
  });

  DiscoverState copyWith({
    List<Project>? allProjects,
    List<Project>? filtered,
    String? selectedFilter,
    String? searchQuery,
    bool? loading,
  }) {
    return DiscoverState(
      allProjects: allProjects ?? this.allProjects,
      filtered: filtered ?? this.filtered,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object> get props =>
      [allProjects, filtered, selectedFilter, searchQuery, loading];
}

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit() : super(const DiscoverState()) {
    _load();
  }

  Future<void> _load() async {
    emit(state.copyWith(loading: true));
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: Replace with DiscoverRepository call
    final projects = MockProjects.discoverProjects;
    emit(state.copyWith(
      loading: false,
      allProjects: projects,
      filtered: projects,
    ));
  }

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
