import 'package:vestie/core/constants/app_strings.dart';

import '../../domain/entities/vff_connection_entity.dart';
import '../../domain/entities/vff_enums.dart';
import '../../domain/entities/vff_inbox_entity.dart';
import '../models/user_vff_hub_ui_model.dart';
import 'user_vff_profile_mapper.dart';

abstract final class UserVffHubMapper {
  static UserVffConnectionRowUi connection(VffConnectionEntity entity) {
    return UserVffConnectionRowUi(
      id: entity.userId,
      name: entity.fullName,
      initials: UserVffHubMapperInitials.initials(entity.fullName),
      photoUrl: entity.profilePhotoUrl,
      mutualLabel: AppStrings.userVffMutualProjects(entity.mutualProjectsCount),
      isPendingSent: entity.isPendingOutgoing,
    );
  }

  static UserVffIncomingRequestUi inboxRequest(VffInboxRequestEntity entity) {
    return UserVffIncomingRequestUi(
      id: entity.requestId,
      projectId: entity.projectId,
      name: entity.senderName,
      initials: UserVffHubMapperInitials.initials(entity.senderName),
      photoUrl: entity.senderPhotoUrl,
      viaProjectName: entity.projectName,
    );
  }

  static UserVffGroupInviteUi projectInvite(VffProjectInviteEntity entity) {
    return UserVffGroupInviteUi(
      id: entity.inviteId,
      projectId: entity.projectId,
      kind: UserVffGroupInviteKind.project,
      titleLine: entity.projectName,
      personInitials: UserVffHubMapperInitials.initials(
        entity.inviterDisplayName,
      ),
      invitedByName: entity.inviterDisplayName,
      primaryIsRequestToJoin:
          entity.joinAction == VffProjectJoinState.requestToJoin ||
          entity.visibility == VffProjectVisibility.private,
    );
  }

  static UserVffSentRowUi sentVffRequest(VffInboxSentRequestEntity entity) {
    return UserVffSentRowUi(
      id: entity.requestId,
      titleLine: entity.receiverDisplayName,
      detailLine: entity.projectName,
      statusLabel: _statusLabel(entity.status),
    );
  }

  static UserVffSentRowUi sentProjectInvite(VffSentProjectInviteEntity entity) {
    return UserVffSentRowUi(
      id: entity.inviteId,
      titleLine: entity.projectName,
      detailLine: entity.inviteeDisplayName,
      statusLabel: _statusLabel(entity.status),
    );
  }

  static UserVffSentRowUi sentJoinRequest(VffSentJoinRequestEntity entity) {
    return UserVffSentRowUi(
      id: entity.membershipId,
      titleLine: entity.projectName,
      detailLine: entity.visibility == VffProjectVisibility.private
          ? 'Private group'
          : 'Public group',
      statusLabel: entity.status,
    );
  }

  static List<UserVffSentRowUi> sentInbox(VffSentInboxEntity inbox) {
    final rows = <UserVffSentRowUi>[
      ...inbox.vffRequests.map(sentVffRequest),
      ...inbox.projectInvites.map(sentProjectInvite),
      ...inbox.joinRequests.map(sentJoinRequest),
    ];
    return rows;
  }

  static String _statusLabel(VffRequestStatus status) {
    return switch (status) {
      VffRequestStatus.accepted => 'Accepted',
      VffRequestStatus.declined => 'Declined',
      _ => 'Pending',
    };
  }
}
