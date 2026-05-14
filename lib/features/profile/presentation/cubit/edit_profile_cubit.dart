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
  /// Non-null after a successful `PUT /users/me` — drives the “updated profile” panel.
  final UserProfile? lastSavedFromServer;
  final String? error;

  const EditProfileState({
    required this.fullName,
    required this.username,
    required this.email,
    this.isSaving = false,
    this.lastSavedFromServer,
    this.error,
  });

  EditProfileState copyWith({
    String? fullName,
    String? username,
    String? email,
    bool? isSaving,
    UserProfile? lastSavedFromServer,
    String? error,
    bool clearError = false,
    bool clearLastSaved = false,
  }) {
    return EditProfileState(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      isSaving: isSaving ?? this.isSaving,
      lastSavedFromServer: clearLastSaved
          ? null
          : (lastSavedFromServer ?? this.lastSavedFromServer),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [fullName, username, email, isSaving, lastSavedFromServer, error];
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

  void setFullName(String v) =>
      emit(state.copyWith(fullName: v, clearLastSaved: true));
  void setUsername(String v) =>
      emit(state.copyWith(username: v, clearLastSaved: true));
  void setEmail(String v) =>
      emit(state.copyWith(email: v, clearLastSaved: true));

  Future<void> _persistLocal(UserProfile p) async {
    final prefs = ServiceLocator.instance.sharedPrefs;
    await prefs.saveString(StorageKeys.userName, p.fullName);
    await prefs.saveString(StorageKeys.userEmail, p.email);
    await prefs.saveString(StorageKeys.userUsername, p.username);
  }

  Future<UserProfile?> save() async {
    final nameErr = ValidationUtils.validateFullName(state.fullName);
    if (nameErr != null) {
      emit(state.copyWith(isSaving: false, error: nameErr));
      return null;
    }
    final userErr =
        ValidationUtils.validateProfileUsernameHandle(state.username);
    if (userErr != null) {
      emit(state.copyWith(isSaving: false, error: userErr));
      return null;
    }
    final emailErr = ValidationUtils.validateEmail(state.email);
    if (emailErr != null) {
      emit(state.copyWith(isSaving: false, error: emailErr));
      return null;
    }

    emit(state.copyWith(
      isSaving: true,
      clearError: true,
      clearLastSaved: true,
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
        ));
        _persistLocal(updated);
        return updated;
      },
    );
  }
}
