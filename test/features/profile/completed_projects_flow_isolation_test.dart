import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_route_args.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_members_only_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_preview_section.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_load_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('Completed profile flow isolation', () {
    test('ProjectDetailRouteArgs defaults keep normal detail behavior', () {
      const args = ProjectDetailRouteArgs(projectId: 'p1');

      expect(args.skipCompletedOutcomeTakeover, isFalse);
      expect(args.refreshHomeOnPop, isFalse);
      expect(args.refreshDiscoverOnPop, isFalse);
    });

    test('outcome load args default to home/dashboard flow', () {
      const loadArgs = SuccessVoteOutcomeLoadRouteArgs(
        projectId: 'p1',
        initialProjectName: 'Trip',
      );

      expect(loadArgs.fromCompletedProjectsList, isFalse);
    });

    test('outcome route args default to dashboard CTA path', () {
      const args = SuccessVoteOutcomeRouteArgs(
        data: SuccessVoteOutcomeUiData(
          isApproved: true,
          amountUsd: 100,
          agreedCount: 1,
          disagreedCount: 0,
          totalMemberCount: 1,
        ),
        viewerRole: SuccessVoteOutcomeRole.member,
      );

      expect(args.fromCompletedProjectsList, isFalse);
      expect(args.projectId, isNull);
    });

    test('GroupMembersRouteArgs keeps default list navigation', () {
      const args = GroupMembersRouteArgs(
        members: <MemberEntity>[],
        projectId: 'p1',
      );

      expect(args.fromCompletedProjectsProfileDetail, isFalse);
      expect(args.project, isNull);
    });

    test('members preview section defaults match home/discover detail', () {
      final section = ProjectMembersPreviewSection(project: _sampleProject);

      expect(section.fromCompletedProjectsProfileDetail, isFalse);
      expect(section.onMemberTap, isNull);
    });

    test('members-only section defaults match home/discover detail', () {
      final section = ProjectDetailMembersOnlySection(project: _sampleProject);

      expect(section.fromCompletedProjectsProfileDetail, isFalse);
      expect(section.onMemberTap, isNull);
    });
  });
}

final _sampleProject = ProjectDetailEntity(
  id: 'p1',
  name: 'Trip',
  category: ProjectCategory.vacations,
  status: ProjectStatus.completed,
  goalAmount: 1000,
  currentAmount: 500,
  endsIn: '',
  announcement: '',
  members: const [],
  borrowRequests: const [],
  viewerRole: ViewerMembershipRole.member,
);
