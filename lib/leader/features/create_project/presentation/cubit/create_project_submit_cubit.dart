import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/features/projects/domain/entities/created_project_entity.dart';
import 'package:vestie/features/projects/domain/usecases/create_and_launch_project_use_case.dart';
import '../../domain/create_project_form.dart';

class CreateProjectSubmitState extends Equatable {
  final bool loading;
  final String? error;
  final String? errorTitle;
  final CreatedProjectEntity? createdProject;

  const CreateProjectSubmitState({
    this.loading = false,
    this.error,
    this.errorTitle,
    this.createdProject,
  });

  CreateProjectSubmitState copyWith({
    bool? loading,
    String? error,
    String? errorTitle,
    CreatedProjectEntity? createdProject,
    bool clearError = false,
  }) {
    return CreateProjectSubmitState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      errorTitle: clearError ? null : (errorTitle ?? this.errorTitle),
      createdProject: createdProject ?? this.createdProject,
    );
  }

  @override
  List<Object?> get props => [loading, error, errorTitle, createdProject];
}

class CreateProjectSubmitCubit extends Cubit<CreateProjectSubmitState> {
  final CreateAndLaunchProjectUseCase _useCase;

  CreateProjectSubmitCubit({CreateAndLaunchProjectUseCase? useCase})
    : _useCase =
          useCase ?? ServiceLocator.instance.createAndLaunchProjectUseCase,
      super(const CreateProjectSubmitState());

  Future<void> submit(CreateProjectForm form) async {
    emit(state.copyWith(loading: true, clearError: true));
    final result = await _useCase(form: form);
    result.fold(
      (failure) => emit(
        state.copyWith(
          loading: false,
          error: failure.message,
          errorTitle: failure.title,
        ),
      ),
      (project) => emit(
        CreateProjectSubmitState(loading: false, createdProject: project),
      ),
    );
  }

  void clearError() {
    if (state.error != null || state.errorTitle != null) {
      emit(state.copyWith(clearError: true));
    }
  }
}
