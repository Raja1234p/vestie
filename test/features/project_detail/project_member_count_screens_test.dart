import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/domain/entities/pagination_info.dart';
import 'package:vestie/core/widgets/common/project_total_members_row.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/pages/group_members_screen.dart';
import 'package:vestie/features/project_detail/presentation/widgets/members_tab.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Screen audit: Home, Discover, completed list, vacation/emergency/investment
/// detail (ongoing + completed), View All, Group Members — same roster floor.
void main() {
  Project listProject({
    required ProjectCategory category,
    required ProjectStatus status,
    required ProjectRelation relation,
    int memberCount = 0,
  }) {
    return Project(
      id: 'p1',
      name: 'Group',
      category: category,
      status: status,
      relation: relation,
      memberCount: memberCount,
    );
  }

  MemberEntity member({
    required String id,
    required String name,
    String status = 'Active',
  }) {
    return MemberEntity(
      id: id,
      initials: name.substring(0, 1),
      name: name,
      status: status,
      role: MemberRole.member,
      contributedAmount: 0,
    );
  }

  ProjectDetailEntity detail({
    ProjectCategory category = ProjectCategory.vacations,
    ProjectStatus status = ProjectStatus.ongoing,
    List<MemberEntity> members = const [],
    PaginationInfo? membersPagination,
  }) {
    return ProjectDetailEntity(
      id: 'p1',
      name: 'Group',
      category: category,
      status: status,
      goalAmount: 1000,
      currentAmount: 0,
      endsIn: '30d',
      announcement: '',
      members: members,
      borrowRequests: const [],
      membersPagination: membersPagination ??
          const PaginationInfo(
            page: 1,
            pageSize: 20,
            totalCount: 0,
            totalPages: 0,
          ),
    );
  }

  group('list cards — Home, Discover, Completed (ProjectCard)', () {
    const categories = [
      ProjectCategory.vacations,
      ProjectCategory.emergency,
      ProjectCategory.investment,
    ];
    const statuses = [ProjectStatus.ongoing, ProjectStatus.completed];
    const relations = [
      ProjectRelation.owned,
      ProjectRelation.joined,
    ];

    test('owner-only API 0 shows 1 on every list card surface', () {
      for (final category in categories) {
        for (final status in statuses) {
          for (final relation in relations) {
            final project = listProject(
              category: category,
              status: status,
              relation: relation,
            );
            expect(project.memberCount, 0, reason: '$category $status $relation');
            expect(project.cardMemberCount, 1, reason: '$category $status $relation');
          }
        }
      }
    });

    test('keeps a real roster count from the list API', () {
      for (final category in categories) {
        final project = listProject(
          category: category,
          status: ProjectStatus.ongoing,
          relation: ProjectRelation.owned,
          memberCount: 5,
        );
        expect(project.cardMemberCount, 5);
        expect(project.memberCount, 5);
      }
    });
  });

  group('detail — ProjectInfoCard / View All / Group Members', () {
    test('owner-only empty roster floors to 1 on all categories and statuses', () {
      for (final category in [
        ProjectCategory.vacations,
        ProjectCategory.emergency,
        ProjectCategory.investment,
      ]) {
        for (final status in [
          ProjectStatus.ongoing,
          ProjectStatus.completed,
        ]) {
          final project = detail(category: category, status: status);
          expect(
            project.displayMemberCount,
            1,
            reason: '$category $status',
          );
        }
      }
    });

    test('uses membersPagination.totalCount when present', () {
      final project = detail(
        membersPagination: const PaginationInfo(
          page: 1,
          pageSize: 20,
          totalCount: 5,
          totalPages: 1,
        ),
      );
      expect(project.displayMemberCount, 5);
    });

    test('counts active members when pagination total is 0', () {
      final project = detail(
        members: [
          member(id: '1', name: 'Ada'),
          member(id: '2', name: 'Ben'),
          member(id: '3', name: 'Cara'),
        ],
      );
      expect(project.displayMemberCount, 3);
    });

    test('excludes pending join rows from the active count', () {
      final project = detail(
        members: [
          member(id: '1', name: 'Ada'),
          member(id: '2', name: 'Ben', status: 'Pending'),
          member(id: '3', name: 'Cara', status: 'JoinPending'),
        ],
      );
      expect(project.displayMemberCount, 1);
    });

    test('pending-only roster still floors to the creator (1)', () {
      final project = detail(
        members: [member(id: '1', name: 'Wait', status: 'Pending')],
      );
      expect(project.displayMemberCount, 1);
    });

    test('View All Members copy matches displayMemberCount', () {
      expect(AppStrings.viewAllMembersWithCount(1), 'View All Members (1)');
      expect(AppStrings.viewAllMembersWithCount(5), 'View All Members (5)');
      expect(AppStrings.viewAllMembersWithCount(0), AppStrings.viewAllMembers);
    });

    test('info card Total Members is always shown (floor never 0)', () {
      expect(detail().displayMemberCount, greaterThan(0));
      expect(
        detail(
          category: ProjectCategory.investment,
          status: ProjectStatus.completed,
        ).displayMemberCount,
        greaterThan(0),
      );
    });

    test('Group Members header uses the same floor as detail', () {
      final ownerOnly = detail();
      expect(
        GroupMembersScreen.headerMemberCount(project: ownerOnly),
        1,
      );
      expect(
        AppStrings.groupMembersTitleWithCount(
          GroupMembersScreen.headerMemberCount(project: ownerOnly),
        ),
        'Group Members (1)',
      );

      final paged = detail(
        membersPagination: const PaginationInfo(
          page: 1,
          pageSize: 20,
          totalCount: 8,
          totalPages: 1,
        ),
      );
      expect(
        GroupMembersScreen.headerMemberCount(project: paged),
        8,
      );
      expect(
        AppStrings.groupMembersTitleWithCount(8),
        'Group Members (8)',
      );
    });

    test('Group Members header floors to 1 when route has no project yet', () {
      expect(
        GroupMembersScreen.headerMemberCount(
          membersTotalCount: 0,
          activeMemberCount: 0,
        ),
        1,
      );
      expect(
        GroupMembersScreen.headerMemberCount(
          membersTotalCount: 4,
          activeMemberCount: 2,
        ),
        4,
      );
    });
  });

  group('vote outcome stays on raw memberCount (not card floor)', () {
    test('API 0 still uses the vote-summary fallback of 7', () {
      final project = listProject(
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        relation: ProjectRelation.owned,
      );
      expect(project.cardMemberCount, 1);
      final data = SuccessVoteOutcomeUiData.fromProject(
        project,
        isApproved: true,
      );
      expect(data.totalMemberCount, 7);
    });

    test('real list memberCount is the vote denominator', () {
      final project = listProject(
        category: ProjectCategory.investment,
        status: ProjectStatus.ongoing,
        relation: ProjectRelation.owned,
        memberCount: 5,
      );
      final data = SuccessVoteOutcomeUiData.fromProject(
        project,
        isApproved: true,
      );
      expect(data.totalMemberCount, 5);
    });
  });

  group('widgets', () {
    Future<void> pumpBody(WidgetTester tester, Widget child) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          builder: (_, _) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: child),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('Total Members row shows owner-only 1', (tester) async {
      await pumpBody(
        tester,
        const ProjectTotalMembersRow(count: 1),
      );
      expect(
        find.text('Total Members: 1', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('Total Members row hides when count is not positive', (
      tester,
    ) async {
      await pumpBody(
        tester,
        const ProjectTotalMembersRow(count: 0),
      );
      expect(
        find.textContaining('Total Members', findRichText: true),
        findsNothing,
      );
    });

    testWidgets('Members tab View All uses owner-only 1', (tester) async {
      await pumpBody(
        tester,
        MembersTab(
          project: detail(),
          members: const [],
          onViewAll: () {},
        ),
      );
      expect(find.text('View All Members (1)'), findsOneWidget);
    });

    testWidgets('Members tab View All uses pagination total', (tester) async {
      await pumpBody(
        tester,
        MembersTab(
          project: detail(
            membersPagination: const PaginationInfo(
              page: 1,
              pageSize: 20,
              totalCount: 5,
              totalPages: 1,
            ),
          ),
          members: const [],
          onViewAll: () {},
        ),
      );
      expect(find.text('View All Members (5)'), findsOneWidget);
    });
  });
}
