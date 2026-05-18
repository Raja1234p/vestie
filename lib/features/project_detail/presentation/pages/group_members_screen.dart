import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_member_row.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_empty_state.dart';

/// Full-screen group members list (View All Members).
class GroupMembersScreen extends StatelessWidget {
  final List<MemberEntity> members;
  final String projectId;
  final ProjectDetailEntity? project;

  const GroupMembersScreen({
    super.key,
    required this.members,
    required this.projectId,
    this.project,
  });

  List<MemberEntity> get _activeMembers => members
      .where((m) => !m.status.toLowerCase().contains('pending'))
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final active = _activeMembers;
    final p = project;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: AppStrings.groupMembersTitle,
                leading: AppBackButton(onPressed: () => context.pop()),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
              sliver: active.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: ProjectMembersEmptyState(centered: true),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final member = active[i];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: ProjectMemberRow(
                              member: member,
                              project: p,
                              onTap: p != null && p.canReviewMemberProfiles
                                  ? (_) =>
                                      ProjectDetailNavigationHelpers
                                          .openMemberProfile(
                                        context,
                                        project: p,
                                        member: member,
                                      )
                                  : null,
                              onAddFriend: p != null &&
                                      p.canReviewMemberProfiles
                                  ? () => ProjectDetailNavigationHelpers
                                      .openAddFriendFlow(context, member)
                                  : null,
                            ),
                          );
                        },
                        childCount: active.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
