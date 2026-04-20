import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_toggle_tab_bar.dart';
import '../../../../core/widgets/common/leader_action_menu.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../cubit/project_detail_cubit.dart';
import '../cubit/project_detail_state.dart';
import '../widgets/announcement_card.dart';
import '../widgets/borrow_requests_tab.dart';
import '../widgets/members_list.dart';
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
        // TODO: navigate to join requests screen
        break;
      case LeaderMenuAction.addAnnouncement:
        // TODO: show announcement bottom sheet
        break;
      case LeaderMenuAction.editProject:
        context.push(AppRoutes.createProjectDetails, extra: true);
        break;
      case LeaderMenuAction.inviteMembers:
        // TODO: navigate to invite screen
        break;
      case LeaderMenuAction.markSuccessful:
        // TODO: confirm dialog then mark successful
        break;
      case LeaderMenuAction.cancelProject:
        // TODO: confirm dialog then cancel
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
            // ── Header ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: project.name,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.grey1100,
                    size: 22.w,
                  ),
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
                    // Announcement card — leader sees trash icon
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
                    SizedBox(height: 10.h),
                    AppButton(
                      text: AppStrings.btnBorrow,
                      onPressed: () {},
                      isSecondary: true,
                    ),
                    SizedBox(height: 20.h),
                    _TabSection(project: project),
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

// ── Tab section ───────────────────────────────────────────────────────────────
class _TabSection extends StatelessWidget {
  final ProjectDetailEntity project;
  const _TabSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
      builder: (context, state) {
        final cubit = context.read<ProjectDetailCubit>();
        final isBorrowTab = state.activeTab == ProjectDetailTab.borrowRequests;
        return Column(
          children: [
            AppToggleTabBar(
              tabs: [AppStrings.tabBorrowRequests, AppStrings.tabMembers],
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
                  ? BorrowRequestsTab(
                      key: const ValueKey('borrow'),
                      requests: project.borrowRequests,
                      onViewAll: () => context.push(
                        AppRoutes.borrowRequests,
                        extra: project.borrowRequests,
                      ),
                    )
                  : MembersList(
                      key: const ValueKey('members'),
                      members: project.members,
                    ),
            ),
          ],
        );
      },
    );
  }
}
