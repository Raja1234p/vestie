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

    return MemberEntity(
      id: fromApi.apiUserId.isNotEmpty ? fromApi.apiUserId : id,
      membershipId: membershipId.isNotEmpty ? membershipId : fromApi.membershipId,
      userId: fromApi.userId.isNotEmpty ? fromApi.userId : userId,
      initials: useApiName ? fromApi.initials : initials,
      name: useApiName ? fromApi.name : name,
      username: fromApi.username.trim().isNotEmpty ? fromApi.username : username,
      status: fromApi.status.trim().isNotEmpty ? fromApi.status : status,
      role: fromApi.role,
      contributedAmount: fromApi.contributedAmount,
      overdueAmount: fromApi.overdueAmount ?? overdueAmount,
    );
  }
}
