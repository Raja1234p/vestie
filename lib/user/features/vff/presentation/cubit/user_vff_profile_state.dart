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

  /// Join / request-to-join on a joined-project row (not footer send-VFF).
  final String? joiningProjectId;

  const UserVffProfileState({
    this.loadStatus = UserVffProfileLoadStatus.initial,
    this.profile,
    this.errorMessage,
    this.projectId,
    this.footerOverride,
    this.isActionLoading = false,
    this.isRemoveVffLoading = false,
    this.vffRequestSent = false,
    this.joiningProjectId,
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
    String? joiningProjectId,
    bool clearJoiningProjectId = false,
  }) {
    return UserVffProfileState(
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      projectId: projectId ?? this.projectId,
      footerOverride: clearFooterOverride
          ? null
          : (footerOverride ?? this.footerOverride),
      isActionLoading: isActionLoading ?? this.isActionLoading,
      isRemoveVffLoading: isRemoveVffLoading ?? this.isRemoveVffLoading,
      vffRequestSent: vffRequestSent ?? this.vffRequestSent,
      joiningProjectId: clearJoiningProjectId
          ? null
          : (joiningProjectId ?? this.joiningProjectId),
    );
  }

  bool get isFooterBusy => isActionLoading || isRemoveVffLoading;

  bool isJoiningProject(String projectId) =>
      joiningProjectId != null && joiningProjectId == projectId.trim();

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
    joiningProjectId,
  ];
}
