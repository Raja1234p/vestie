import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/domain/usecases/update_me_use_case.dart';
import '../../domain/entities/user_profile.dart';

class EditProfileState extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final bool isSaving;
  final bool saved;
  final String? error;

  const EditProfileState({
    required this.fullName,
    required this.username,
    required this.email,
    this.isSaving = false,
    this.saved = false,
    this.error,
  });

  EditProfileState copyWith({
    String? fullName,
    String? username,
    String? email,
    bool? isSaving,
    bool? saved,
    String? error,
    bool clearError = false,
  }) {
    return EditProfileState(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      isSaving: isSaving ?? this.isSaving,
      saved: saved ?? this.saved,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [fullName, username, email, isSaving, saved, error];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateMeUseCase _updateMeUseCase;

  EditProfileCubit(UserProfile initial)
      : _updateMeUseCase = ServiceLocator.instance.updateMeUseCase,
        super(EditProfileState(
          fullName: initial.fullName,
          username: initial.username,
          email: initial.email,
        ));

  void setFullName(String v) => emit(state.copyWith(fullName: v));
  void setUsername(String v) => emit(state.copyWith(username: v));
  void setEmail(String v)    => emit(state.copyWith(email: v));

  Future<UserProfile?> save() async {
    emit(state.copyWith(isSaving: true, clearError: true));

    final parts = state.fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isEmpty ? '' : parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final result = await _updateMeUseCase(
      firstName: firstName,
      lastName: lastName,
      userName: state.username.trim(),
      photoUrl: '',
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, error: failure.message));
        return null;
      },
      (user) {
        final updated = UserProfile(
          fullName: user.name,
          username: state.username.trim().isEmpty
              ? user.email.split('@').first
              : state.username.trim(),
          email: user.email,
        );
        emit(state.copyWith(isSaving: false, saved: true));
        return updated;
      },
    );
  }
}
