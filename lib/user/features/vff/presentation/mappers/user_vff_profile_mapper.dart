import 'package:vestie/core/utils/formatters.dart';

import '../../domain/entities/vff_enums.dart';
import '../../domain/entities/vff_profile_entity.dart';
import '../models/user_vff_profile_ui_model.dart';

abstract final class UserVffProfileMapper {
  static UserVffProfileUiModel connected(VffConnectedProfileEntity entity) {
    return UserVffProfileUiModel(
      id: entity.userId,
      usernameHandle: _username(entity.username),
      displayName: entity.fullName,
      initials: UserVffHubMapperInitials.initials(entity.fullName),
      photoUrl: entity.profilePhotoUrl,
      mutualProjectsCount: entity.mutualProjectsCount,
      badgeMode: UserVffProfileBadgeMode.vffVerified,
      metricsLayout: UserVffMetricsLayout.trioCounters,
      metrics: _metrics(entity.stats, trio: true),
      joinedProjects: entity.joinedProjects
          .map((p) => _joinedProject(p))
          .toList(growable: false),
      footerMode: UserVffProfileFooterMode.followingSheet,
    );
  }

  static UserVffProfileUiModel public(
    VffPublicProfileEntity entity, {
    required bool canSendVffRequest,
  }) {
    final connected = entity.isVffConnected;
    return UserVffProfileUiModel(
      id: entity.userId,
      usernameHandle: _username(entity.username),
      displayName: entity.fullName,
      initials: UserVffHubMapperInitials.initials(entity.fullName),
      photoUrl: entity.profilePhotoUrl,
      mutualProjectsCount: 0,
      badgeMode: connected
          ? UserVffProfileBadgeMode.vffVerified
          : UserVffProfileBadgeMode.member,
      metricsLayout: connected
          ? UserVffMetricsLayout.trioCounters
          : UserVffMetricsLayout.contributedPair,
      metrics: _metrics(entity.stats, trio: connected),
      joinedProjects: connected
          ? entity.joinedProjects
                .map((p) => _joinedProject(p))
                .toList(growable: false)
          : null,
      footerMode: connected
          ? UserVffProfileFooterMode.followingSheet
          : (canSendVffRequest
                ? UserVffProfileFooterMode.sendRequest
                : UserVffProfileFooterMode.sendRequest),
      showFooter: connected || canSendVffRequest,
    );
  }

  static UserVffMetricsUi _metrics(
    VffProfileStatsEntity stats, {
    required bool trio,
  }) {
    return UserVffMetricsUi(
      contributedDisplay: AppFormatters.formatCurrency(
        stats.totalContributedAmount,
      ),
      contributionsDisplay: '${stats.contributionCount}',
      projectsDisplay: trio ? '${stats.joinedProjectsCount}' : null,
    );
  }

  static UserVffJoinedProjectRowUi _joinedProject(
    VffJoinedProjectEntity entity,
  ) {
    return UserVffJoinedProjectRowUi(
      projectId: entity.projectId,
      title: entity.name,
      memberCount: entity.memberCount,
      action: _joinAction(entity.joinState),
      isInvestment: _isInvestmentProject(entity.type),
    );
  }

  static bool _isInvestmentProject(String? type) {
    final normalized = (type ?? '').trim().toLowerCase();
    return normalized.contains('invest');
  }

  static UserVffJoinedProjectAction _joinAction(VffProjectJoinState state) {
    return switch (state) {
      VffProjectJoinState.alreadyMember => UserVffJoinedProjectAction.joined,
      VffProjectJoinState.requestToJoin =>
        UserVffJoinedProjectAction.requestToJoin,
      VffProjectJoinState.requestSent ||
      VffProjectJoinState.pending => UserVffJoinedProjectAction.requestSentChip,
      _ => UserVffJoinedProjectAction.join,
    };
  }

  static String _username(String? raw) {
    final handle = (raw ?? '').trim();
    if (handle.isEmpty) return '';
    return handle.startsWith('@') ? handle.substring(1) : handle;
  }
}

/// Shared initials helper for hub + profile mappers.
abstract final class UserVffHubMapperInitials {
  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'NA';
    String c(String s) => s.isEmpty ? 'N' : s[0].toUpperCase();
    return '${c(parts.first)}${c(parts.length > 1 ? parts.last : parts.first)}';
  }
}
