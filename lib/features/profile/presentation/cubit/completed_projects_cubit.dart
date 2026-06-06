import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/features/projects/domain/usecases/list_projects_use_case.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/mock_projects.dart';

class CompletedProjectsState extends Equatable {
  final List<Project> projects;
  final bool loading;
  final String? errorMessage;

  const CompletedProjectsState({
    this.projects = const [],
    this.loading = false,
    this.errorMessage,
  });

  CompletedProjectsState copyWith({
    List<Project>? projects,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CompletedProjectsState(
      projects: projects ?? this.projects,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [projects, loading, errorMessage];
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

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    final result = await _listProjectsUseCase(scope: 'mine');
    result.fold(
      (failure) =>
          emit(state.copyWith(loading: false, errorMessage: failure.message)),
      (projects) {
        var completed =
            projects.where((p) => p.status == ProjectStatus.completed).toList()
              ..sort((a, b) => a.name.compareTo(b.name));
        if (completed.isEmpty && previewDemoWhenEmpty) {
          completed = List<Project>.of(MockProjects.previewCompletedProjects)
            ..sort((a, b) => a.name.compareTo(b.name));
        }
        emit(state.copyWith(loading: false, projects: completed));
      },
    );
  }
}
