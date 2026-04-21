import 'borrow_request_entity.dart';
import 'member_entity.dart';
import 'project_detail_entity.dart';

class ProjectDetailRouteArgs {
  final ProjectDetailEntity project;

  const ProjectDetailRouteArgs({required this.project});
}

class BorrowRequestsRouteArgs {
  final List<BorrowRequestEntity> requests;
  final bool isLeaderMode;

  const BorrowRequestsRouteArgs({
    required this.requests,
    this.isLeaderMode = false,
  });
}

class MemberDetailRouteArgs {
  final MemberEntity member;
  final String projectName;
  final bool isLeaderView;

  const MemberDetailRouteArgs({
    required this.member,
    required this.projectName,
    this.isLeaderView = false,
  });
}
