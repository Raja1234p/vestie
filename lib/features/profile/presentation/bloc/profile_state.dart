import '../../../../core/bloc/base_state.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class ProfileState extends BaseState<UserProfileEntity> {
  const ProfileState();
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;
  final String? title;

  const ProfileError({required this.message, this.title});

  @override
  List<Object?> get props => [message, title];
}
