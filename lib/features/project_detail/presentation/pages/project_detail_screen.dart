import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_invite_members_dialog.dart';
import '../../../../core/widgets/common/app_toggle_tab_bar.dart';
import '../../../../core/widgets/common/leader_action_menu.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/entities/project_detail_route_args.dart';
import '../cubit/project_detail_cubit.dart';
import '../cubit/project_detail_state.dart';
import '../widgets/announcement_card.dart';
import '../widgets/project_detail_tab_panels.dart';
import '../widgets/project_info_card.dart';

/// Shell — provides ProjectDetailCubit. Route extra = [ProjectDetailEntity].
class ProjectDetailScreen extends StatelessWidget {
  final ProjectDetailEntity project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectDetailCubit(),
      child: _ProjectDetailBody(project: project),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _ProjectDetailBody extends StatelessWidget {
  final ProjectDetailEntity project;
  const _ProjectDetailBody({required this.project});

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
        child: BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
          builder: (context, state) {
            if (state.status == ProjectDetailViewStatus.error) {
              return Center(
                child: Text(
                  state.errorMessage ?? AppStrings.errorGeneric,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textBody,
                      ),
                ),
              );
            }

            if (state.status == ProjectDetailViewStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: PostAuthHeader(
                    title: project.name,
                    leading: AppBackButton(
                      onPressed: () => context.pop(),
                    ),
                    // "..." leader menu only visible to project owner
                    trailing: project.isLeader
                        ? LeaderActionMenu(
                            joinRequestCount: 3,
                            onSelected: (action) =>
                                _handleLeaderAction(context, action),
                          )
                        : null,
                  ),
                ),

                // ── Content ─────────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: 12.h),
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
                          onPressed: () =>
                              context.push(AppRoutes.transactionAmount),
                        ),
                        SizedBox(height: 13.h),
                        AppButton(
                          text: AppStrings.btnBorrow,
                          onPressed: () => context
                              .read<ProjectDetailCubit>()
                              .selectTab(ProjectDetailTab.borrowRequests),
                          isSecondary: true,
                        ),
                        SizedBox(height: 20.h),
                        _TabSection(
                          project: project,
                          onMemberTap: (member) {
                            context.push(
                              AppRoutes.memberDetail,
                              extra: MemberDetailRouteArgs(
                                member: member,
                                projectName: project.name,
                                isLeaderView: project.isLeader,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Tab section ───────────────────────────────────────────────────────────────
class _TabSection extends StatelessWidget {
  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity> onMemberTap;

  const _TabSection({
    required this.project,
    required this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
      builder: (context, state) {
        final cubit = context.read<ProjectDetailCubit>();
        final isBorrowTab = state.activeTab == ProjectDetailTab.borrowRequests;
        return Column(
          children: [
            AppToggleTabBar(
              tabs: [
                AppStrings.tabBorrowRequests,
                project.isLeader
                    ? AppStrings.tabManageMembers
                    : AppStrings.tabMember,
              ],
              activeIndex: isBorrowTab ? 0 : 1,
              onTabSelected: (i) => cubit.selectTab(
                i == 0
                    ? ProjectDetailTab.borrowRequests
                    : ProjectDetailTab.members,
              ),
            ),
            SizedBox(height: 16.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: isBorrowTab
                  ? project.isLeader
                      ? LeaderBorrowRequestsPanel(
                          key: const ValueKey('leader-borrow'),
                          requests: project.borrowRequests,
                          onViewAll: () => context.push(
                            AppRoutes.borrowRequests,
                            extra: BorrowRequestsRouteArgs(
                              requests: project.borrowRequests,
                              isLeaderMode: true,
                            ),
                          ),
                        )
                      : UserBorrowRequestsPanel(
                          key: const ValueKey('user-borrow'),
                          requests: project.borrowRequests,
                          onViewAll: () => context.push(
                            AppRoutes.borrowRequests,
                            extra: BorrowRequestsRouteArgs(
                              requests: project.borrowRequests,
                              isLeaderMode: false,
                            ),
                          ),
                        )
                  : project.isLeader
                      ? LeaderMembersPanel(
                          key: const ValueKey('leader-members'),
                          members: project.members,
                          onMemberTap: onMemberTap,
                        )
                      : UserMembersPanel(
                          key: const ValueKey('user-members'),
                          members: project.members,
                          onMemberTap: onMemberTap,
                        ),
            ),
          ],
        );
      },
    );
  }
}
