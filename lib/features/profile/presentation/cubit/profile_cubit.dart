import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/user_profile.dart';
import '../../../auth/domain/usecases/logout_use_case.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/constants/storage_keys.dart';
import 'package:vestie/features/dashboard/domain/dashboard_prefetch.dart';

class ProfileState extends Equatable {
  final UserProfile profile;
  final File? avatarFile;
  final bool isLoading;
  final bool isLogoutSuccess;
  final String? error;

  const ProfileState({
    required this.profile,
    this.avatarFile,
    this.isLoading = false,
    this.isLogoutSuccess = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? profile,
    File? avatarFile,
    bool? isLoading,
    bool? isLogoutSuccess,
    String? error,
  }) =>
      ProfileState(
        profile: profile ?? this.profile,
        avatarFile: avatarFile ?? this.avatarFile,
        isLoading: isLoading ?? this.isLoading,
        isLogoutSuccess: isLogoutSuccess ?? this.isLogoutSuccess,
        error: error,
      );

  @override
  List<Object?> get props => [profile, avatarFile, isLoading, isLogoutSuccess, error];
}

class ProfileCubit extends Cubit<ProfileState> {
  final LogoutUseCase _logoutUseCase;

  ProfileCubit({LogoutUseCase? logoutUseCase})
      : _logoutUseCase = logoutUseCase ?? ServiceLocator.instance.logoutUseCase,
        super(const ProfileState(
          profile: UserProfile(fullName: '', username: '', email: ''),
        ));

  final _picker = ImagePicker();
  bool _tabBootstrapped = false;

  /// Called when the Profile tab is first shown. Skips `GET /users/me` if [HomeBloc] already loaded it.
  Future<void> ensureTabVisible() async {
    if (_tabBootstrapped) return;
    _tabBootstrapped = true;
    if (DashboardPrefetch.userMeLoadedOnDashboard) {
      await _hydrateFromPrefsOnly();
      return;
    }
    await loadProfile();
  }

  Future<void> _hydrateFromPrefsOnly() async {
    final prefs = ServiceLocator.instance.sharedPrefs;
    final name = await prefs.getString(StorageKeys.userName) ?? '';
    final email = await prefs.getString(StorageKeys.userEmail) ?? '';
    final handle = await prefs.getString(StorageKeys.userUsername) ?? '';
    emit(state.copyWith(
      isLoading: false,
      profile: UserProfile(
        fullName: name,
        email: email,
        username: handle.isNotEmpty
            ? handle
            : (email.contains('@') ? email.split('@').first : ''),
      ),
    ));
  }

  Future<void> loadProfile() async {
    // 1. Try to load from SharedPreferences first for instant UI
    final name = await ServiceLocator.instance.sharedPrefs
            .getString(StorageKeys.userName) ??
        '';
    final email = await ServiceLocator.instance.sharedPrefs
            .getString(StorageKeys.userEmail) ??
        '';

    final handle = await ServiceLocator.instance.sharedPrefs
            .getString(StorageKeys.userUsername) ??
        '';

    if (name.isNotEmpty || email.isNotEmpty) {
      emit(state.copyWith(
        profile: UserProfile(
          fullName: name,
          email: email,
          username: handle.isNotEmpty
              ? handle
              : (email.contains('@') ? email.split('@').first : ''),
        ),
      ));
    }

    // 2. Refresh from API to ensure data is up to date
    emit(state.copyWith(isLoading: true));
    final result = await ServiceLocator.instance.authRepository.getMe();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (user) {
        final userName = user.userName.isNotEmpty
            ? user.userName
            : (user.email.contains('@')
                ? user.email.split('@').first
                : '');
        final updatedProfile = UserProfile(
          fullName: user.name,
          email: user.email,
          username: userName,
        );
        emit(state.copyWith(
          isLoading: false,
          profile: updatedProfile,
        ));

        // Update local storage with fresh data
        ServiceLocator.instance.sharedPrefs
            .saveString(StorageKeys.userName, user.name);
        ServiceLocator.instance.sharedPrefs
            .saveString(StorageKeys.userEmail, user.email);
        ServiceLocator.instance.sharedPrefs
            .saveString(StorageKeys.userUsername, userName);
      },
    );
  }

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

  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));

    final refreshToken = await ServiceLocator.instance.secureStorage
        .getString(StorageKeys.refreshToken);

    if (refreshToken == null) {
      await _clearLocalData();
      emit(state.copyWith(isLoading: false, isLogoutSuccess: true));
      return;
    }

    final result = await _logoutUseCase(refreshToken: refreshToken);

    await result.fold(
      (failure) async {
        // Even if API fails, we clear local data for safety
        await _clearLocalData();
        emit(state.copyWith(isLoading: false, isLogoutSuccess: true));
      },
      (_) async {
        await _clearLocalData();
        emit(state.copyWith(isLoading: false, isLogoutSuccess: true));
      },
    );
  }

  Future<void> _clearLocalData() async {
    DashboardPrefetch.reset();
    await ServiceLocator.instance.authRepository.clearRiskDisclaimerLocalCache();
    await ServiceLocator.instance.secureStorage.remove(StorageKeys.accessToken);
    await ServiceLocator.instance.secureStorage.remove(StorageKeys.refreshToken);
    await ServiceLocator.instance.sharedPrefs.saveBool(StorageKeys.isLoggedIn, false);
  }
}
