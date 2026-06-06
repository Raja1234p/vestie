import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

ProjectDetailEntity _vacationLeaderProject({required bool hasCoLeader}) {
  return ProjectDetailEntity(
    id: 'p1',
    name: 'Trip',
    category: ProjectCategory.vacations,
    status: ProjectStatus.ongoing,
    goalAmount: 1000,
    currentAmount: 0,
    endsIn: '',
    announcement: '',
    members: [],
    borrowRequests: [],
    viewerRole: ViewerMembershipRole.groupLeader,
    borrowingEnabled: true,
    hasCoLeader: hasCoLeader,
  );
}

void main() {
  test('vacation group leader cannot borrow without co-leader', () {
    final project = _vacationLeaderProject(hasCoLeader: false);

    expect(project.isBorrowDisabledForViewer, isTrue);
    expect(project.canViewerBorrow, isFalse);
  });

  test('vacation group leader can borrow after co-leader is assigned', () {
    final project = _vacationLeaderProject(hasCoLeader: true);

    expect(project.isBorrowDisabledForViewer, isFalse);
    expect(project.canViewerBorrow, isTrue);
  });

  test('members are not blocked by co-leader requirement', () {
    const project = ProjectDetailEntity(
      id: 'p1',
      name: 'Trip',
      category: ProjectCategory.vacations,
      status: ProjectStatus.ongoing,
      goalAmount: 1000,
      currentAmount: 0,
      endsIn: '',
      announcement: '',
      members: [],
      borrowRequests: [],
      viewerRole: ViewerMembershipRole.member,
      borrowingEnabled: true,
      hasCoLeader: false,
    );

    expect(project.isBorrowDisabledForViewer, isFalse);
    expect(project.canViewerBorrow, isTrue);
  });
}
