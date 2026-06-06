import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/features/projects/domain/usecases/update_project_use_case.dart';
import '../../domain/create_project_form.dart';

class CreateProjectUpdateState extends Equatable {
  final bool loading;
  final String? error;
  final String? errorTitle;

  const CreateProjectUpdateState({
    this.loading = false,
    this.error,
    this.errorTitle,
  });

  CreateProjectUpdateState copyWith({
    bool? loading,
    String? error,
    String? errorTitle,
    bool clearError = false,
  }) {
    return CreateProjectUpdateState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      errorTitle: clearError ? null : (errorTitle ?? this.errorTitle),
    );
  }

  @override
  List<Object?> get props => [loading, error, errorTitle];
}

class CreateProjectUpdateCubit extends Cubit<CreateProjectUpdateState> {
  final UpdateProjectUseCase _useCase;

  CreateProjectUpdateCubit({UpdateProjectUseCase? useCase})
    : _useCase = useCase ?? ServiceLocator.instance.updateProjectUseCase,
      super(const CreateProjectUpdateState());

  Future<bool> submit(CreateProjectForm form) async {
    final projectId = form.editingProjectId;
    if (projectId == null || projectId.isEmpty) return false;

    emit(state.copyWith(loading: true, clearError: true));
    final result = await _useCase(projectId: projectId, form: form);
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            loading: false,
            error: failure.message,
            errorTitle: failure.title,
          ),
        );
        return false;
      },
      (_) {
        emit(const CreateProjectUpdateState(loading: false));
        return true;
      },
    );
  }

  void clearError() {
    if (state.error != null || state.errorTitle != null) {
      emit(state.copyWith(clearError: true));
    }
  }
}
