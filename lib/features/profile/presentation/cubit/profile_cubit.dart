import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/update_me_photo.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/delete_me_profile_picture_use_case.dart';
import '../../../auth/domain/usecases/get_me_use_case.dart';
import '../../../../core/auth/app_auth_session.dart';
import '../../../auth/domain/usecases/logout_use_case.dart';
import '../../../auth/domain/usecases/update_me_use_case.dart';
import '../../data/profile_prefs.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/account_deletion_eligibility_entity.dart';
import '../../domain/usecases/check_account_deletion_eligibility_use_case.dart';
import '../../domain/usecases/delete_account_use_case.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/onboarding_prefs.dart';
import '../../../../core/utils/username_input_formatter.dart';
import 'package:vestie/features/dashboard/domain/dashboard_prefetch.dart';
import 'package:vestie/features/bank_accounts/domain/bank_accounts_cache.dart';
import 'package:vestie/features/kyc/domain/kyc_status_cache.dart';
import 'package:vestie/features/payment_methods/domain/payment_methods_cache.dart';
import 'package:vestie/features/stripe/domain/stripe_config_cache.dart';
import 'package:vestie/core/realtime/projects_signalr_service.dart';
import 'package:vestie/core/realtime/wallet_signalr_service.dart';
import 'package:vestie/core/services/fcm_push_service.dart';
import 'package:vestie/features/wallet/domain/wallet_balance_cache.dart';

class ProfileState extends Equatable {
  final UserProfile profile;
  final bool isLoading;
  final bool isLoggingOut;
  final bool isLogoutSuccess;
  final String? error;

  const ProfileState({
    required this.profile,
    this.isLoading = false,
    this.isLoggingOut = false,
    this.isLogoutSuccess = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isLoggingOut,
    bool? isLogoutSuccess,
    String? error,
  }) => ProfileState(
    profile: profile ?? this.profile,
    isLoading: isLoading ?? this.isLoading,
    isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    isLogoutSuccess: isLogoutSuccess ?? this.isLogoutSuccess,
    error: error,
  );

  bool get hasProfilePhoto =>
      profile.photoUrl != null && profile.photoUrl!.trim().isNotEmpty;

  @override
  List<Object?> get props => [
    profile,
    isLoading,
    isLoggingOut,
    isLogoutSuccess,
    error,
  ];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    LogoutUseCase? logoutUseCase,
    UpdateMeUseCase? updateMeUseCase,
    DeleteMeProfilePictureUseCase? deleteMeProfilePictureUseCase,
    GetMeUseCase? getMeUseCase,
    CheckAccountDeletionEligibilityUseCase? checkDeletionEligibilityUseCase,
    DeleteAccountUseCase? deleteAccountUseCase,
  }) : _logoutUseCase = logoutUseCase ?? ServiceLocator.instance.logoutUseCase,
       _updateMeUseCase =
           updateMeUseCase ?? ServiceLocator.instance.updateMeUseCase,
       _deleteMeProfilePictureUseCase =
           deleteMeProfilePictureUseCase ??
           ServiceLocator.instance.deleteMeProfilePictureUseCase,
       _getMeUseCase = getMeUseCase ?? ServiceLocator.instance.getMeUseCase,
       _checkDeletionEligibilityUseCase =
           checkDeletionEligibilityUseCase ??
           ServiceLocator.instance.checkAccountDeletionEligibilityUseCase,
       _deleteAccountUseCase =
           deleteAccountUseCase ?? ServiceLocator.instance.deleteAccountUseCase,
       super(
         const ProfileState(
           profile: UserProfile(
             firstName: '',
             lastName: '',
             username: '',
             email: '',
           ),
         ),
       );

  final LogoutUseCase _logoutUseCase;
  final UpdateMeUseCase _updateMeUseCase;
  final DeleteMeProfilePictureUseCase _deleteMeProfilePictureUseCase;
  final GetMeUseCase _getMeUseCase;
  final CheckAccountDeletionEligibilityUseCase _checkDeletionEligibilityUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  static const _profileSyncTtl = Duration(minutes: 3);

  Future<void>? _loadInFlight;
  DateTime? _lastSuccessfulSync;
  bool _hasLoadedOnce = false;

  /// First open loads from cache then API; re-opens skip network if synced recently.
  Future<void> ensureTabVisible() async {
    await loadProfile(
      silent: _hasLoadedOnce,
      skipNetworkIfFresh: _hasLoadedOnce,
    );
  }

  /// After edit profile — always sync, without loading shimmer when cache exists.
  Future<void> refreshProfile() async {
    await loadProfile(silent: true, skipNetworkIfFresh: false);
  }

  Future<void> loadProfile({
    bool silent = false,
    bool skipNetworkIfFresh = false,
  }) async {
    if (_loadInFlight != null) {
      await _loadInFlight;
      return;
    }

    _loadInFlight = _loadProfileImpl(
      silent: silent,
      skipNetworkIfFresh: skipNetworkIfFresh,
    );
    try {
      await _loadInFlight;
    } finally {
      _loadInFlight = null;
    }
  }

  Future<void> _loadProfileImpl({
    required bool silent,
    required bool skipNetworkIfFresh,
  }) async {
    final cached = await ProfilePrefs.load();
    final hasCache = cached.fullName.isNotEmpty || cached.email.isNotEmpty;
    if (hasCache) {
      emit(state.copyWith(profile: cached, error: null));
    }

    if (skipNetworkIfFresh && _isProfileSyncFresh) return;

    if (!silent && !hasCache) {
      emit(state.copyWith(isLoading: true, error: null));
    }

    final result = await _getMeUseCase();

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            isLoading: false,
            error: FailureMapper.userMessage(failure),
          ),
        );
      },
      (user) async {
        final profile = ProfilePrefs.fromUser(user);
        await ProfilePrefs.persist(profile);
        _lastSuccessfulSync = DateTime.now();
        _hasLoadedOnce = true;
        emit(state.copyWith(isLoading: false, profile: profile, error: null));
      },
    );
  }

  bool get _isProfileSyncFresh {
    final last = _lastSuccessfulSync;
    if (last == null) return false;
    return DateTime.now().difference(last) < _profileSyncTtl;
  }

  /// Uploads a new profile photo. Returns `null` on success, else user-facing error.
  Future<String?> uploadPhotoFile(String filePath) {
    return _updateProfilePhoto(UpdateMePhotoUpload(filePath));
  }

  /// Removes profile photo via `DELETE /users/me/profile-picture`.
  Future<String?> removeAvatar() async {
    final deleteResult = await _deleteMeProfilePictureUseCase();
    if (isClosed) return null;

    final deleteError = deleteResult.fold(
      (failure) => FailureMapper.userMessage(failure),
      (_) => null,
    );
    if (deleteError != null) return deleteError;

    return _syncProfileFromServer();
  }

  Future<String?> _updateProfilePhoto(UpdateMePhoto photo) async {
    final profile = state.profile;

    final updateResult = await _updateMeUseCase(
      firstName: profile.firstName.trim(),
      lastName: profile.lastName.trim(),
      userName: UsernameInputFormatter.normalize(profile.username),
      photo: photo,
    );

    if (isClosed) return null;

    final updateError = updateResult.fold(
      (failure) => FailureMapper.userMessage(failure),
      (_) => null,
    );
    if (updateError != null) return updateError;

    return _syncProfileFromServer();
  }

  Future<String?> _syncProfileFromServer() async {
    final syncResult = await _getMeUseCase();
    if (isClosed) return null;

    User? syncedUser;
    String? syncError;
    syncResult.fold(
      (failure) => syncError = FailureMapper.userMessage(failure),
      (user) => syncedUser = user,
    );
    if (syncError != null) return syncError;

    await _applySyncedUser(syncedUser!);
    return null;
  }

  Future<void> _applySyncedUser(User user) async {
    final profile = ProfilePrefs.fromUser(user);
    await ProfilePrefs.persist(profile);
    _lastSuccessfulSync = DateTime.now();
    _hasLoadedOnce = true;
    emit(state.copyWith(profile: profile));
  }

  Future<Either<Failure, AccountDeletionEligibilityEntity>>
  checkDeletionEligibility() => _checkDeletionEligibilityUseCase();

  Future<({bool success, String? errorMessage})> deleteAccountConfirmed() async {
    final result = await _deleteAccountUseCase();
    return result.fold(
      (failure) => (
        success: false,
        errorMessage: FailureMapper.userMessage(failure),
      ),
      (_) async {
        await _clearLocalData();
        emit(state.copyWith(isLogoutSuccess: true));
        return (success: true, errorMessage: null);
      },
    );
  }

  Future<void> logout() async {
    emit(state.copyWith(isLoggingOut: true));

    final refreshToken = await ServiceLocator.instance.secureStorage.getString(
      StorageKeys.refreshToken,
    );

    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearLocalData();
      emit(state.copyWith(isLoggingOut: false, isLogoutSuccess: true));
      return;
    }

    final result = await _logoutUseCase(refreshToken: refreshToken);

    await result.fold(
      (_) async {
        await _clearLocalData();
        emit(state.copyWith(isLoggingOut: false, isLogoutSuccess: true));
      },
      (_) async {
        await _clearLocalData();
        emit(state.copyWith(isLoggingOut: false, isLogoutSuccess: true));
      },
    );
  }

  Future<void> _clearLocalData() async {
    await FcmPushService.unregisterStoredToken();
    await ProjectsSignalRService.instance.disconnect();
    await WalletSignalRService.instance.disconnect();
    DashboardPrefetch.reset();
    WalletBalanceCache.clear();
    PaymentMethodsCache.clear();
    BankAccountsCache.clear();
    StripeConfigCache.clear();
    KycStatusCache.clear();
    BankAccountsCache.clear();
    await ServiceLocator.instance.authRepository
        .clearRiskDisclaimerLocalCache();
    await ProfilePrefs.clear();
    await ServiceLocator.instance.secureStorage.remove(StorageKeys.accessToken);
    await ServiceLocator.instance.secureStorage.remove(
      StorageKeys.refreshToken,
    );
    await ServiceLocator.instance.sharedPrefs.saveBool(
      StorageKeys.isLoggedIn,
      false,
    );
    await OnboardingPrefs.markCompleted();
    AppAuthSession.instance.markLoggedOut();
  }
}
