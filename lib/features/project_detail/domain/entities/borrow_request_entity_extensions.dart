import 'borrow_request_entity.dart';
import 'member_entity.dart';
import 'member_entity_extensions.dart';

extension BorrowRequestMemberLookup on BorrowRequestEntity {
  /// Resolves the project member for this borrow request (API `userId` or display name).
  MemberEntity? resolveMember(List<MemberEntity> members) {
    final requestUserId = id.trim();
    if (requestUserId.isNotEmpty) {
      for (final member in members) {
        if (member.apiUserId == requestUserId) return member;
      }
    }

    final targetName = memberName.trim().toLowerCase();
    if (targetName.isEmpty) return null;

    for (final member in members) {
      if (member.name.trim().toLowerCase() == targetName) return member;
    }
    return null;
  }
}
