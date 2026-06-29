import 'package:vestie/core/domain/entities/pagination_info.dart';
import 'vff_enums.dart';

class VffInboxRequestEntity {
  final String requestId;
  final String projectId;
  final String projectName;
  final String? projectType;
  final String senderUserId;
  final String senderName;
  final String? senderUserName;
  final String? senderPhotoUrl;
  final VffRequestStatus status;
  final DateTime? createdUtc;

  const VffInboxRequestEntity({
    required this.requestId,
    required this.projectId,
    required this.projectName,
    this.projectType,
    required this.senderUserId,
    required this.senderName,
    this.senderUserName,
    this.senderPhotoUrl,
    this.status = VffRequestStatus.pending,
    this.createdUtc,
  });
}

class VffInboxSentRequestEntity {
  final String requestId;
  final String projectId;
  final String projectName;
  final String receiverUserId;
  final String receiverDisplayName;
  final String? senderPhotoUrl;
  final VffRequestStatus status;
  final DateTime? createdUtc;

  const VffInboxSentRequestEntity({
    required this.requestId,
    required this.projectId,
    required this.projectName,
    required this.receiverUserId,
    required this.receiverDisplayName,
    this.senderPhotoUrl,
    this.status = VffRequestStatus.pending,
    this.createdUtc,
  });
}

class VffProjectInviteEntity {
  final String inviteId;
  final String projectId;
  final String projectName;
  final VffProjectVisibility visibility;
  final String inviterUserId;
  final String inviterDisplayName;
  final String? photoUrl;
  final VffRequestStatus status;
  final VffProjectJoinState? joinAction;
  final DateTime? createdUtc;

  const VffProjectInviteEntity({
    required this.inviteId,
    required this.projectId,
    required this.projectName,
    this.visibility = VffProjectVisibility.public,
    required this.inviterUserId,
    required this.inviterDisplayName,
    this.photoUrl,
    this.status = VffRequestStatus.pending,
    this.joinAction,
    this.createdUtc,
  });
}

class VffSentProjectInviteEntity {
  final String inviteId;
  final String projectId;
  final String projectName;
  final VffProjectVisibility visibility;
  final String inviteeUserId;
  final String inviteeDisplayName;
  final String? senderPhotoUrl;
  final VffRequestStatus status;
  final DateTime? createdUtc;

  const VffSentProjectInviteEntity({
    required this.inviteId,
    required this.projectId,
    required this.projectName,
    this.visibility = VffProjectVisibility.public,
    required this.inviteeUserId,
    required this.inviteeDisplayName,
    this.senderPhotoUrl,
    this.status = VffRequestStatus.pending,
    this.createdUtc,
  });
}

class VffSentJoinRequestEntity {
  final String membershipId;
  final String projectId;
  final String projectName;
  final VffProjectVisibility visibility;
  final String status;
  final DateTime? createdUtc;

  const VffSentJoinRequestEntity({
    required this.membershipId,
    required this.projectId,
    required this.projectName,
    this.visibility = VffProjectVisibility.public,
    required this.status,
    this.createdUtc,
  });
}

class VffReceivedInboxEntity {
  final List<VffInboxRequestEntity> vffRequests;
  final PaginationInfo vffRequestsPagination;
  final List<VffProjectInviteEntity> projectInvites;
  final PaginationInfo projectInvitesPagination;

  const VffReceivedInboxEntity({
    this.vffRequests = const [],
    required this.vffRequestsPagination,
    this.projectInvites = const [],
    required this.projectInvitesPagination,
  });
}

class VffSentInboxEntity {
  final List<VffInboxSentRequestEntity> vffRequests;
  final PaginationInfo vffRequestsPagination;
  final List<VffSentProjectInviteEntity> projectInvites;
  final PaginationInfo projectInvitesPagination;
  final List<VffSentJoinRequestEntity> joinRequests;
  final PaginationInfo joinRequestsPagination;

  const VffSentInboxEntity({
    this.vffRequests = const [],
    required this.vffRequestsPagination,
    this.projectInvites = const [],
    required this.projectInvitesPagination,
    this.joinRequests = const [],
    required this.joinRequestsPagination,
  });
}

class VffInviteResultEntity {
  final String inviteId;
  final String projectId;
  final String inviteeUserId;
  final String status;
  final String? membershipStatus;

  const VffInviteResultEntity({
    required this.inviteId,
    required this.projectId,
    required this.inviteeUserId,
    required this.status,
    this.membershipStatus,
  });
}

class VffJoinFromVffResultEntity {
  final String projectId;
  final String membershipId;
  final String status;
  final String role;

  const VffJoinFromVffResultEntity({
    required this.projectId,
    required this.membershipId,
    required this.status,
    required this.role,
  });
}

class VffSendRequestResultEntity {
  final String id;
  final String projectId;
  final VffRequestStatus status;

  const VffSendRequestResultEntity({
    required this.id,
    required this.projectId,
    this.status = VffRequestStatus.pending,
  });
}

class VffRemoveConnectionResultEntity {
  final bool success;
  final String message;

  const VffRemoveConnectionResultEntity({
    required this.success,
    required this.message,
  });
}
