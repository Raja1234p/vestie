import 'package:equatable/equatable.dart';

import '../models/user_vff_profile_ui_model.dart';

enum UserVffProfileLoadStatus { initial, loading, loaded, error }

final class UserVffProfileState extends Equatable {
  final UserVffProfileLoadStatus loadStatus;
  final UserVffProfileUiModel? profile;
  final String? errorMessage;
  final String? projectId;
  final UserVffProfileFooterMode? footerOverride;
  final bool isActionLoading;
  final bool isRemoveVffLoading;
  final bool vffRequestSent;

  const UserVffProfileState({
    this.loadStatus = UserVffProfileLoadStatus.initial,
    this.profile,
    this.errorMessage,
    this.projectId,
    this.footerOverride,
    this.isActionLoading = false,
    this.isRemoveVffLoading = false,
    this.vffRequestSent = false,
  });

  UserVffProfileFooterMode? get effectiveFooterMode =>
      footerOverride ?? profile?.footerMode;

  bool get showsRequestSentRibbon =>
      effectiveFooterMode == UserVffProfileFooterMode.requestSent;

  UserVffProfileState copyWith({
    UserVffProfileLoadStatus? loadStatus,
    UserVffProfileUiModel? profile,
    String? errorMessage,
    bool clearError = false,
    String? projectId,
    UserVffProfileFooterMode? footerOverride,
    bool clearFooterOverride = false,
    bool? isActionLoading,
    bool? isRemoveVffLoading,
    bool? vffRequestSent,
  }) {
    return UserVffProfileState(
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      projectId: projectId ?? this.projectId,
      footerOverride:
          clearFooterOverride ? null : (footerOverride ?? this.footerOverride),
      isActionLoading: isActionLoading ?? this.isActionLoading,
      isRemoveVffLoading: isRemoveVffLoading ?? this.isRemoveVffLoading,
      vffRequestSent: vffRequestSent ?? this.vffRequestSent,
    );
  }

  bool get isFooterBusy => isActionLoading || isRemoveVffLoading;

  @override
  List<Object?> get props => [
        loadStatus,
        profile,
        errorMessage,
        projectId,
        footerOverride,
        isActionLoading,
        isRemoveVffLoading,
        vffRequestSent,
      ];
}
