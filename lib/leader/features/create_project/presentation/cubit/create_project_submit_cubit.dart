import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/features/projects/domain/usecases/create_project_use_case.dart';
import '../../domain/create_project_form.dart';

class CreateProjectSubmitState extends Equatable {
  final bool loading;
  final String? error;
  final String? createdProjectId;

  const CreateProjectSubmitState({
    this.loading = false,
    this.error,
    this.createdProjectId,
  });

  CreateProjectSubmitState copyWith({
    bool? loading,
    String? error,
    String? createdProjectId,
    bool clearError = false,
  }) {
    return CreateProjectSubmitState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      createdProjectId: createdProjectId ?? this.createdProjectId,
    );
  }

  @override
  List<Object?> get props => [loading, error, createdProjectId];
}

class CreateProjectSubmitCubit extends Cubit<CreateProjectSubmitState> {
  final CreateProjectUseCase _useCase;

  CreateProjectSubmitCubit({CreateProjectUseCase? useCase})
      : _useCase = useCase ?? ServiceLocator.instance.createProjectUseCase,
        super(const CreateProjectSubmitState());

  Future<void> submit(CreateProjectForm form) async {
    emit(state.copyWith(loading: true, clearError: true));
    final result = await _useCase(form: form);
    result.fold(
      (failure) => emit(state.copyWith(loading: false, error: failure.message)),
      (id) => emit(state.copyWith(loading: false, createdProjectId: id)),
    );
  }
}

