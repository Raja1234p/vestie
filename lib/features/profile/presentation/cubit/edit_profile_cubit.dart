import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_me_use_case.dart';
import '../../../auth/domain/usecases/update_me_use_case.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/username_input_formatter.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../data/profile_prefs.dart';
import '../../domain/entities/user_profile.dart';

class EditProfileState extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final bool isSaving;
  final String? fullNameError;
  final String? usernameError;
  final String? emailError;
  final String? error;

  const EditProfileState({
    required this.fullName,
    required this.username,
    required this.email,
    this.isSaving = false,
    this.fullNameError,
    this.usernameError,
    this.emailError,
    this.error,
  });

  EditProfileState copyWith({
    String? fullName,
    String? username,
    String? email,
    bool? isSaving,
    String? fullNameError,
    String? usernameError,
    String? emailError,
    String? error,
    bool clearFullNameError = false,
    bool clearUsernameError = false,
    bool clearEmailError = false,
    bool clearError = false,
    bool clearAllFieldErrors = false,
  }) {
    return EditProfileState(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      isSaving: isSaving ?? this.isSaving,
      fullNameError: clearAllFieldErrors || clearFullNameError
          ? null
          : (fullNameError ?? this.fullNameError),
      usernameError: clearAllFieldErrors || clearUsernameError
          ? null
          : (usernameError ?? this.usernameError),
      emailError: clearAllFieldErrors || clearEmailError
          ? null
          : (emailError ?? this.emailError),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        username,
        email,
        isSaving,
        fullNameError,
        usernameError,
        emailError,
        error,
      ];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(UserProfile initial)
      : _updateMeUseCase = ServiceLocator.instance.updateMeUseCase,
        _getMeUseCase = ServiceLocator.instance.getMeUseCase,
        super(EditProfileState(
          fullName: initial.fullName,
          username: initial.username,
          email: initial.email,
        ));

  final UpdateMeUseCase _updateMeUseCase;
  final GetMeUseCase _getMeUseCase;

  void setFullName(String v) => emit(state.copyWith(
        fullName: v,
        clearFullNameError: true,
        clearError: true,
      ));

  void setUsername(String v) => emit(state.copyWith(
        username: v,
        clearUsernameError: true,
        clearError: true,
      ));

  Future<UserProfile?> save() async {
    final nameErr = ValidationUtils.validateFullName(state.fullName);
    final userErr =
        ValidationUtils.validateProfileUsernameHandle(state.username);
    final emailErr = ValidationUtils.validateEmail(state.email);

    if (nameErr != null || userErr != null || emailErr != null) {
      emit(state.copyWith(
        fullNameError: nameErr,
        usernameError: userErr,
        emailError: emailErr,
      ));
      return null;
    }

    emit(state.copyWith(
      isSaving: true,
      clearError: true,
      clearAllFieldErrors: true,
    ));

    final parts = state.fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isEmpty ? '' : parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final updateResult = await _updateMeUseCase(
      firstName: firstName,
      lastName: lastName,
      userName: UsernameInputFormatter.normalize(state.username),
    );

    User? updatedUser;
    final updateFailed = updateResult.fold(
      (failure) {
        emit(state.copyWith(
          isSaving: false,
          error: FailureMapper.userMessage(failure),
        ));
        return true;
      },
      (user) {
        updatedUser = user;
        return false;
      },
    );
    if (updateFailed || updatedUser == null) return null;

    final syncResult = await _getMeUseCase();
    if (isClosed) return null;

    String? syncError;
    User? syncedUser;
    syncResult.fold(
      (failure) => syncError = FailureMapper.userMessage(failure),
      (user) => syncedUser = user,
    );
    if (syncError != null) {
      emit(state.copyWith(isSaving: false, error: syncError));
      return null;
    }

    final profile = ProfilePrefs.fromUser(syncedUser!);

    await ProfilePrefs.persist(profile);

    emit(state.copyWith(
      fullName: profile.fullName,
      username: profile.username,
      email: profile.email,
      isSaving: false,
      clearAllFieldErrors: true,
    ));
    return profile;
  }
}
