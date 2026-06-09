import 'borrow_request_entity.dart';
import 'member_entity.dart';
import 'member_entity_extensions.dart';
import 'project_detail_entity.dart';
import 'project_detail_entity_extensions.dart';

extension BorrowRequestViewer on BorrowRequestEntity {
  /// Requesters cannot vote on their own pending borrow request.
  bool isRequestedByViewer(ProjectDetailEntity project) {
    final viewerId = project.viewerUserId;
    final requestUserId = memberId.trim();
    if (viewerId == null || requestUserId.isEmpty) return false;
    return viewerId == requestUserId;
  }
}

extension BorrowRequestMemberLookup on BorrowRequestEntity {
  /// Resolves the project member for this borrow request (API `memberId` or display name).
  MemberEntity? resolveMember(List<MemberEntity> members) {
    final requestUserId = memberId.trim();
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
