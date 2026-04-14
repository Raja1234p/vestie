import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';

class EditProfileState extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final bool isSaving;
  final bool saved;

  const EditProfileState({
    required this.fullName,
    required this.username,
    required this.email,
    this.isSaving = false,
    this.saved = false,
  });

  EditProfileState copyWith({
    String? fullName,
    String? username,
    String? email,
    bool? isSaving,
    bool? saved,
  }) {
    return EditProfileState(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      isSaving: isSaving ?? this.isSaving,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object> get props => [fullName, username, email, isSaving, saved];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(UserProfile initial)
      : super(EditProfileState(
          fullName: initial.fullName,
          username: initial.username,
          email: initial.email,
        ));

  void setFullName(String v) => emit(state.copyWith(fullName: v));
  void setUsername(String v) => emit(state.copyWith(username: v));
  void setEmail(String v)    => emit(state.copyWith(email: v));

  Future<UserProfile?> save() async {
    emit(state.copyWith(isSaving: true));
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: call ProfileRepository.updateProfile(...)
    emit(state.copyWith(isSaving: false, saved: true));
    return UserProfile(
      fullName: state.fullName,
      username: state.username,
      email: state.email,
    );
  }
}
