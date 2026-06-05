import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

import 'member_entity.dart';

extension MemberEntityApiIds on MemberEntity {
  /// `POST/DELETE …/members/{userId}/co-leader` — prefer API `userId`.
  String get apiUserId {
    final uid = userId.trim();
    if (uid.isNotEmpty) return uid;
    return id.trim();
  }

  bool matchesIdentity(MemberEntity other) {
    final a = apiUserId;
    final b = other.apiUserId;
    if (a.isNotEmpty && b.isNotEmpty) return a == b;

    final membershipA = membershipId.trim();
    final membershipB = other.membershipId.trim();
    if (membershipA.isNotEmpty && membershipB.isNotEmpty) {
      return membershipA == membershipB;
    }
    return false;
  }

  /// Activity API supplies display fields; list/route [seed] keeps role + membership ids.
  MemberEntity mergedWithActivity(MemberEntity fromApi) {
    if (!matchesIdentity(fromApi)) return fromApi;

    final apiName = fromApi.name.trim();
    final useApiName = apiName.isNotEmpty && apiName != 'Member';

    final mergedRole = switch (fromApi.role) {
      MemberRole.leader => MemberRole.leader,
      MemberRole.coLeader => MemberRole.coLeader,
      MemberRole.member => role,
    };

    final mergedPhoto = fromApi.photoUrl?.trim();
    final useApiPhoto =
        mergedPhoto != null && mergedPhoto.isNotEmpty;

    return MemberEntity(
      id: fromApi.apiUserId.isNotEmpty ? fromApi.apiUserId : id,
      membershipId: membershipId.isNotEmpty ? membershipId : fromApi.membershipId,
      userId: fromApi.userId.isNotEmpty ? fromApi.userId : userId,
      initials: useApiName ? fromApi.initials : initials,
      name: useApiName ? fromApi.name : name,
      username: fromApi.username.trim().isNotEmpty ? fromApi.username : username,
      status: fromApi.status.trim().isNotEmpty ? fromApi.status : status,
      role: mergedRole,
      contributedAmount: fromApi.contributedAmount,
      overdueAmount: fromApi.overdueAmount ?? overdueAmount,
      photoUrl: useApiPhoto ? fromApi.photoUrl : photoUrl,
      vffAdded: fromApi.isVffConnected || fromApi.vffAdded,
      vffConnectionState: _mergedVffConnectionState(fromApi),
      canSendVffRequest: fromApi.canSendVffRequest,
      pendingVffRequestId: fromApi.pendingVffRequestId ?? pendingVffRequestId,
    );
  }

  /// Trust activity API for disconnect; keep route seed only for optimistic pending.
  VffConnectionState _mergedVffConnectionState(MemberEntity fromApi) {
    if (fromApi.isVffConnected || fromApi.hasPendingVffOutgoing) {
      return fromApi.vffConnectionState;
    }
    if (fromApi.vffConnectionState != VffConnectionState.none) {
      return fromApi.vffConnectionState;
    }
    if (hasPendingVffOutgoing) return vffConnectionState;
    return VffConnectionState.none;
  }
}
