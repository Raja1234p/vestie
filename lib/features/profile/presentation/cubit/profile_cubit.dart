import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/mock_profile_data.dart';

class ProfileState extends Equatable {
  final UserProfile profile;
  final File? avatarFile;

  const ProfileState({required this.profile, this.avatarFile});

  ProfileState copyWith({UserProfile? profile, File? avatarFile}) =>
      ProfileState(
        profile: profile ?? this.profile,
        avatarFile: avatarFile ?? this.avatarFile,
      );

  @override
  List<Object?> get props => [profile, avatarFile];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit()
      : super(ProfileState(profile: MockProfileData.profile));

  final _picker = ImagePicker();

  Future<void> pickAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 400,
    );
    if (picked != null) {
      emit(state.copyWith(avatarFile: File(picked.path)));
    }
  }

  void updateProfile(UserProfile updated) =>
      emit(state.copyWith(profile: updated));
}
