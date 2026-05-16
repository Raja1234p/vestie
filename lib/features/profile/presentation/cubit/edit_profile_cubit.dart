import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../auth/domain/usecases/update_me_use_case.dart';
import '../../domain/entities/user_profile.dart';

class EditProfileState extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final bool isSaving;
  final String? fullNameError;
  final String? usernameError;
  final String? emailError;
  /// API / server failures only (not field validation).
  final String? error;
  final UserProfile? lastSavedFromServer;

  const EditProfileState({
    required this.fullName,
    required this.username,
    required this.email,
    this.isSaving = false,
    this.fullNameError,
    this.usernameError,
    this.emailError,
    this.error,
    this.lastSavedFromServer,
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
    UserProfile? lastSavedFromServer,
    bool clearFullNameError = false,
    bool clearUsernameError = false,
    bool clearEmailError = false,
    bool clearError = false,
    bool clearLastSaved = false,
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
      lastSavedFromServer: clearLastSaved
          ? null
          : (lastSavedFromServer ?? this.lastSavedFromServer),
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
        lastSavedFromServer,
      ];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateMeUseCase _updateMeUseCase;
  String _photoUrlForApi;

  EditProfileCubit(
    UserProfile initial, {
    String photoUrlForApi = '',
  })  : _updateMeUseCase = ServiceLocator.instance.updateMeUseCase,
        _photoUrlForApi = photoUrlForApi,
        super(EditProfileState(
          fullName: initial.fullName,
          username: initial.username,
          email: initial.email,
        ));

  void setFullName(String v) => emit(state.copyWith(
        fullName: v,
        clearLastSaved: true,
        clearFullNameError: true,
        clearError: true,
      ));

  void setUsername(String v) => emit(state.copyWith(
        username: v,
        clearLastSaved: true,
        clearUsernameError: true,
        clearError: true,
      ));

  void setEmail(String v) => emit(state.copyWith(
        email: v,
        clearLastSaved: true,
        clearEmailError: true,
        clearError: true,
      ));

  Future<void> _persistLocal(UserProfile p) async {
    final prefs = ServiceLocator.instance.sharedPrefs;
    await prefs.saveString(StorageKeys.userName, p.fullName);
    await prefs.saveString(StorageKeys.userEmail, p.email);
    await prefs.saveString(StorageKeys.userUsername, p.username);
  }

  Future<UserProfile?> save() async {
    final nameErr = ValidationUtils.validateFullName(state.fullName);
    final userErr =
        ValidationUtils.validateProfileUsernameHandle(state.username);
    final emailErr = ValidationUtils.validateEmail(state.email);

    if (nameErr != null || userErr != null || emailErr != null) {
      emit(EditProfileState(
        fullName: state.fullName,
        username: state.username,
        email: state.email,
        isSaving: false,
        fullNameError: nameErr,
        usernameError: userErr,
        emailError: emailErr,
        lastSavedFromServer: state.lastSavedFromServer,
      ));
      return null;
    }

    emit(state.copyWith(
      isSaving: true,
      clearError: true,
      clearLastSaved: true,
      clearAllFieldErrors: true,
    ));

    final parts = state.fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isEmpty ? '' : parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final result = await _updateMeUseCase(
      firstName: firstName,
      lastName: lastName,
      userName: state.username.trim().replaceFirst(RegExp(r'^@+'), ''),
      photoUrl: _photoUrlForApi,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, error: failure.message));
        return null;
      },
      (user) {
        _photoUrlForApi = user.photoUrl ?? _photoUrlForApi;
        final userName = user.userName.isNotEmpty
            ? user.userName
            : state.username.trim().replaceFirst(RegExp(r'^@+'), '');
        final updated = UserProfile(
          fullName: user.name,
          username: userName,
          email: user.email,
        );
        emit(state.copyWith(
          fullName: updated.fullName,
          username: updated.username,
          email: updated.email,
          isSaving: false,
          lastSavedFromServer: updated,
          clearAllFieldErrors: true,
        ));
        _persistLocal(updated);
        return updated;
      },
    );
  }
}
