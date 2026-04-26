import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_invite_members_dialog.dart';
import '../../../../core/widgets/common/leader_action_menu.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../../home/domain/entities/project.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/entities/project_detail_route_args.dart';
import '../widgets/announcement_card.dart';
import '../widgets/project_detail_user_completed_content.dart';
import '../widgets/members_list.dart';
import '../widgets/project_info_card.dart';

class InvestmentProjectDetailScreen extends StatelessWidget {
  final ProjectDetailEntity project;

  const InvestmentProjectDetailScreen({super.key, required this.project});

  bool get _isCompleted => project.status == ProjectStatus.completed;

  void _openMemberDetail(BuildContext context, MemberEntity member) {
    context.push(
      AppRoutes.memberDetail,
      extra: MemberDetailRouteArgs(
        member: member,
        projectName: project.name,
        isLeaderView: project.isLeader,
      ),
    );
  }

  void _handleLeaderAction(BuildContext context, LeaderMenuAction action) {
    switch (action) {
      case LeaderMenuAction.joinRequests:
        context.push(AppRoutes.joinRequests);
        break;
      case LeaderMenuAction.addAnnouncement:
        context.push(AppRoutes.createAnnouncement);
        break;
      case LeaderMenuAction.editProject:
        context.push(AppRoutes.createProjectDetails, extra: true);
        break;
      case LeaderMenuAction.inviteMembers:
        AppInviteMembersDialog.show(context);
        break;
      case LeaderMenuAction.markSuccessful:
        context.push(
          AppRoutes.markProjectSuccessful,
          extra: MarkSuccessfulRouteArgs(
            memberCount: project.members.length,
          ),
        );
        break;
      case LeaderMenuAction.cancelProject:
        final unpaid = project.members
            .where(
              (m) => m.overdueAmount != null && m.overdueAmount! > 0,
            )
            .length;
        context.push(
          AppRoutes.cancelProject,
          extra: CancelProjectRouteArgs(
            projectName: project.name,
            membersWithUnpaidBorrows: unpaid,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: project.name,
                leading: AppBackButton(
                  onPressed: () => context.pop(),
                ),
                trailing: project.isLeader
                    ? LeaderActionMenu(
                        joinRequestCount: 3,
                        onSelected: (action) =>
                            _handleLeaderAction(context, action),
                      )
                    : null,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverToBoxAdapter(
                child: _isCompleted
                    ? ProjectDetailUserCompletedContent(
                        project: project,
                        onMemberTap: (m) => _openMemberDetail(context, m),
                        onDeleteAnnouncement: project.isLeader
                            ? () {
                                // TODO: delete announcement via BLoC
                              }
                            : null,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnnouncementCard(
                            text: project.announcement,
                            isLeader: project.isLeader,
                            onDelete: () {
                              // TODO: delete announcement via BLoC
                            },
                          ),
                          SizedBox(height: 12.h),
                          ProjectInfoCard(project: project),
                          SizedBox(height: 16.h),
                          AppButton(
                            text: AppStrings.btnContribute,
                            onPressed: () => context.push(
                              AppRoutes.contributeFlow,
                              extra: ProjectWalletFlowArgs.fromProject(project),
                            ),
                          ),
                          SizedBox(height: 13.h),
                          AppButton(
                            text: AppStrings.btnBorrow,
                            onPressed: () => context.push(
                              AppRoutes.borrowFlow,
                              extra: ProjectWalletFlowArgs.fromProject(project),
                            ),
                            isSecondary: true,
                          ),
                          SizedBox(height: 16.h),
                          AppText(
                            AppStrings.tabMembers,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey1100,
                                ),
                          ),
                          SizedBox(height: 14.h),
                          MembersList(
                            members: project.members,
                            onMemberTap: (m) =>
                                _openMemberDetail(context, m),
                          ),
                          SizedBox(height: 32.h),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
