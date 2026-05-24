import 'package:vestie/core/utils/safe_parser.dart';

import '../../domain/entities/vff_enums.dart';
import '../../domain/entities/vff_inbox_entity.dart';
import 'vff_json_parsing.dart';

class VffInboxRequestModel {
  final VffInboxRequestEntity entity;

  const VffInboxRequestModel(this.entity);

  factory VffInboxRequestModel.fromJson(Map<String, dynamic> json) {
    return VffInboxRequestModel(
      VffInboxRequestEntity(
        requestId: VffJsonParsing.readString(json, const ['requestId', 'id']),
        projectId: json.safeString('projectId'),
        projectName: json.safeString('projectName'),
        projectType: json.safeStringNullable('projectType'),
        senderUserId: VffJsonParsing.readString(json, const [
          'senderUserId',
          'senderId',
        ]),
        senderName: VffJsonParsing.readString(json, const [
          'senderName',
          'senderDisplayName',
        ]),
        senderUserName: json.safeStringNullable('senderUserName'),
        senderPhotoUrl: _optionalPhoto(json, const [
          'senderPhoto',
          'photoURL',
          'senderPhotoUrl',
        ]),
        status: VffRequestStatus.parse(json.safeStringNullable('status')),
        createdUtc: VffJsonParsing.parseUtc(json.safeStringNullable('createdUtc')),
      ),
    );
  }

  VffInboxRequestEntity toEntity() => entity;

  static String? _optionalPhoto(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final raw = VffJsonParsing.readString(json, keys);
    return raw.isEmpty ? null : raw;
  }
}

class VffInboxSentRequestModel {
  final VffInboxSentRequestEntity entity;

  const VffInboxSentRequestModel(this.entity);

  factory VffInboxSentRequestModel.fromJson(Map<String, dynamic> json) {
    return VffInboxSentRequestModel(
      VffInboxSentRequestEntity(
        requestId: VffJsonParsing.readString(json, const ['requestId', 'id']),
        projectId: json.safeString('projectId'),
        projectName: json.safeString('projectName'),
        receiverUserId: json.safeString('receiverUserId'),
        receiverDisplayName: json.safeString('receiverDisplayName'),
        senderPhotoUrl: VffInboxRequestModel._optionalPhoto(json, const [
          'senderPhoto',
          'photoURL',
        ]),
        status: VffRequestStatus.parse(json.safeStringNullable('status')),
        createdUtc: VffJsonParsing.parseUtc(json.safeStringNullable('createdUtc')),
      ),
    );
  }

  VffInboxSentRequestEntity toEntity() => entity;
}

class VffProjectInviteModel {
  final VffProjectInviteEntity entity;

  const VffProjectInviteModel(this.entity);

  factory VffProjectInviteModel.fromJson(Map<String, dynamic> json) {
    return VffProjectInviteModel(
      VffProjectInviteEntity(
        inviteId: VffJsonParsing.readString(json, const ['inviteId', 'id']),
        projectId: json.safeString('projectId'),
        projectName: json.safeString('projectName'),
        visibility: VffProjectVisibility.parse(json.safeStringNullable('visibility')),
        inviterUserId: json.safeString('inviterUserId'),
        inviterDisplayName: json.safeString('inviterDisplayName'),
        photoUrl: VffInboxRequestModel._optionalPhoto(json, const [
          'photoURL',
          'inviterPhotoUrl',
        ]),
        status: VffRequestStatus.parse(json.safeStringNullable('status')),
        joinAction: _joinAction(json),
        createdUtc: VffJsonParsing.parseUtc(json.safeStringNullable('createdUtc')),
      ),
    );
  }

  VffProjectInviteEntity toEntity() => entity;

  static VffProjectJoinState? _joinAction(Map<String, dynamic> json) {
    final raw = json.safeStringNullable('joinAction');
    if (raw == null || raw.isEmpty) return null;
    return VffProjectJoinState.parse(raw);
  }
}

class VffSentProjectInviteModel {
  final VffSentProjectInviteEntity entity;

  const VffSentProjectInviteModel(this.entity);

  factory VffSentProjectInviteModel.fromJson(Map<String, dynamic> json) {
    return VffSentProjectInviteModel(
      VffSentProjectInviteEntity(
        inviteId: VffJsonParsing.readString(json, const ['inviteId', 'id']),
        projectId: json.safeString('projectId'),
        projectName: json.safeString('projectName'),
        visibility: VffProjectVisibility.parse(json.safeStringNullable('visibility')),
        inviteeUserId: json.safeString('inviteeUserId'),
        inviteeDisplayName: json.safeString('inviteeDisplayName'),
        senderPhotoUrl: VffInboxRequestModel._optionalPhoto(json, const [
          'senderPhoto',
          'photoURL',
        ]),
        status: VffRequestStatus.parse(json.safeStringNullable('status')),
        createdUtc: VffJsonParsing.parseUtc(json.safeStringNullable('createdUtc')),
      ),
    );
  }

  VffSentProjectInviteEntity toEntity() => entity;
}

class VffSentJoinRequestModel {
  final VffSentJoinRequestEntity entity;

  const VffSentJoinRequestModel(this.entity);

  factory VffSentJoinRequestModel.fromJson(Map<String, dynamic> json) {
    return VffSentJoinRequestModel(
      VffSentJoinRequestEntity(
        membershipId: json.safeString('membershipId'),
        projectId: json.safeString('projectId'),
        projectName: json.safeString('projectName'),
        visibility: VffProjectVisibility.parse(json.safeStringNullable('visibility')),
        status: json.safeString('status'),
        createdUtc: VffJsonParsing.parseUtc(json.safeStringNullable('createdUtc')),
      ),
    );
  }

  VffSentJoinRequestEntity toEntity() => entity;
}

class VffReceivedInboxModel {
  final VffReceivedInboxEntity entity;

  const VffReceivedInboxModel(this.entity);

  factory VffReceivedInboxModel.fromJson(Map<String, dynamic> json) {
    final vffRequests = json
        .safeList('vffRequests')
        .whereType<Map>()
        .map((m) => VffInboxRequestModel.fromJson(m.cast<String, dynamic>()))
        .map((m) => m.toEntity())
        .toList(growable: false);
    final projectInvites = json
        .safeList('projectInvites')
        .whereType<Map>()
        .map((m) => VffProjectInviteModel.fromJson(m.cast<String, dynamic>()))
        .map((m) => m.toEntity())
        .toList(growable: false);

    return VffReceivedInboxModel(
      VffReceivedInboxEntity(
        vffRequests: vffRequests,
        projectInvites: projectInvites,
      ),
    );
  }

  VffReceivedInboxEntity toEntity() => entity;
}

class VffSentInboxModel {
  final VffSentInboxEntity entity;

  const VffSentInboxModel(this.entity);

  factory VffSentInboxModel.fromJson(Map<String, dynamic> json) {
    final vffRequests = json
        .safeList('vffRequests')
        .whereType<Map>()
        .map((m) => VffInboxSentRequestModel.fromJson(m.cast<String, dynamic>()))
        .map((m) => m.toEntity())
        .toList(growable: false);
    final projectInvites = json
        .safeList('projectInvites')
        .whereType<Map>()
        .map((m) => VffSentProjectInviteModel.fromJson(m.cast<String, dynamic>()))
        .map((m) => m.toEntity())
        .toList(growable: false);
    final joinRequests = json
        .safeList('joinRequests')
        .whereType<Map>()
        .map((m) => VffSentJoinRequestModel.fromJson(m.cast<String, dynamic>()))
        .map((m) => m.toEntity())
        .toList(growable: false);

    return VffSentInboxModel(
      VffSentInboxEntity(
        vffRequests: vffRequests,
        projectInvites: projectInvites,
        joinRequests: joinRequests,
      ),
    );
  }

  VffSentInboxEntity toEntity() => entity;
}

class VffInviteResultModel {
  final VffInviteResultEntity entity;

  const VffInviteResultModel(this.entity);

  factory VffInviteResultModel.fromJson(Map<String, dynamic> json) {
    return VffInviteResultModel(
      VffInviteResultEntity(
        inviteId: VffJsonParsing.readString(json, const ['inviteId', 'id']),
        projectId: json.safeString('projectId'),
        inviteeUserId: json.safeString('inviteeUserId'),
        status: json.safeString('status'),
        membershipStatus: json.safeStringNullable('membershipStatus'),
      ),
    );
  }

  VffInviteResultEntity toEntity() => entity;
}

class VffJoinFromVffResultModel {
  final VffJoinFromVffResultEntity entity;

  const VffJoinFromVffResultModel(this.entity);

  factory VffJoinFromVffResultModel.fromJson(Map<String, dynamic> json) {
    return VffJoinFromVffResultModel(
      VffJoinFromVffResultEntity(
        projectId: json.safeString('projectId'),
        membershipId: json.safeString('membershipId'),
        status: json.safeString('status'),
        role: json.safeString('role'),
      ),
    );
  }

  VffJoinFromVffResultEntity toEntity() => entity;
}

class VffSendRequestResultModel {
  final VffSendRequestResultEntity entity;

  const VffSendRequestResultModel(this.entity);

  factory VffSendRequestResultModel.fromJson(Map<String, dynamic> json) {
    return VffSendRequestResultModel(
      VffSendRequestResultEntity(
        id: VffJsonParsing.readString(json, const ['id', 'requestId']),
        projectId: json.safeString('projectId'),
        status: VffRequestStatus.parse(json.safeStringNullable('status')),
      ),
    );
  }

  VffSendRequestResultEntity toEntity() => entity;
}

class VffRemoveConnectionResultModel {
  final VffRemoveConnectionResultEntity entity;

  const VffRemoveConnectionResultModel(this.entity);

  factory VffRemoveConnectionResultModel.fromJson(Map<String, dynamic> json) {
    return VffRemoveConnectionResultModel(
      VffRemoveConnectionResultEntity(
        success: json.safeBool('success'),
        message: json.safeString('message'),
      ),
    );
  }

  VffRemoveConnectionResultEntity toEntity() => entity;
}
