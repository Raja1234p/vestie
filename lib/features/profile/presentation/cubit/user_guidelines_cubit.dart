import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/user_guidelines_page.dart';
import '../../domain/usecases/get_user_guidelines_use_case.dart';

class UserGuidelinesState extends Equatable {
  const UserGuidelinesState({
    this.loading = false,
    this.loadFailed = false,
    this.errorMessage,
    this.page,
  });

  final bool loading;
  final bool loadFailed;
  final String? errorMessage;
  final UserGuidelinesPage? page;

  UserGuidelinesState copyWith({
    bool? loading,
    bool? loadFailed,
    String? errorMessage,
    UserGuidelinesPage? page,
    bool clearError = false,
    bool clearPage = false,
  }) {
    return UserGuidelinesState(
      loading: loading ?? this.loading,
      loadFailed: loadFailed ?? this.loadFailed,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      page: clearPage ? null : (page ?? this.page),
    );
  }

  @override
  List<Object?> get props => [loading, loadFailed, errorMessage, page];
}

class UserGuidelinesCubit extends Cubit<UserGuidelinesState> {
  UserGuidelinesCubit({GetUserGuidelinesUseCase? getUserGuidelinesUseCase})
    : _getUserGuidelinesUseCase =
          getUserGuidelinesUseCase ??
          ServiceLocator.instance.getUserGuidelinesUseCase,
      super(const UserGuidelinesState(loading: true)) {
    load();
  }

  final GetUserGuidelinesUseCase _getUserGuidelinesUseCase;

  Future<void> load() async {
    emit(
      state.copyWith(
        loading: true,
        loadFailed: false,
        clearError: true,
      ),
    );

    final result = await _getUserGuidelinesUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          loading: false,
          loadFailed: true,
          errorMessage: FailureMapper.userMessage(failure),
          clearPage: true,
        ),
      ),
      (page) => emit(
        state.copyWith(
          loading: false,
          loadFailed: false,
          page: page,
          clearError: true,
        ),
      ),
    );
  }
}
