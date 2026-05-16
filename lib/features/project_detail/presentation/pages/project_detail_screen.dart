import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/app_toggle_tab_bar.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/di/service_locator.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import '../navigation/open_project_from_card.dart';
import '../navigation/project_detail_navigation_helpers.dart';
import '../widgets/announcement_card.dart';
import '../widgets/project_detail_tab_panels.dart';
import 'package:vestie/user/features/project_detail/presentation/widgets/project_detail_user_completed_content.dart';
import '../widgets/project_detail_trailing_actions.dart';
import '../widgets/project_detail_load_error.dart';
import '../widgets/project_detail_loading_body.dart';
import '../widgets/project_detail_wallet_actions.dart';
import '../widgets/project_info_card.dart';

/// Loads `GET /projects/{id}` via [ProjectDetailBloc] on open.
class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  final String? initialProjectName;
  final bool refreshHomeOnPop;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.initialProjectName,
    this.refreshHomeOnPop = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !refreshHomeOnPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !refreshHomeOnPop) return;
        popProjectDetailNavigation(context, refreshHomeOnPop: true);
      },
      child: BlocProvider(
        create: (_) => ServiceLocator.instance.createProjectDetailBloc()
          ..add(LoadProjectDetailEvent(projectId: projectId)),
        child: _ProjectDetailBody(
          projectId: projectId,
          initialProjectName: initialProjectName,
          refreshHomeOnPop: refreshHomeOnPop,
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _ProjectDetailBody extends StatelessWidget {
  const _ProjectDetailBody({
    required this.projectId,
    required this.initialProjectName,
    required this.refreshHomeOnPop,
  });

  final String projectId;
  final String? initialProjectName;
  final bool refreshHomeOnPop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
          builder: (context, state) {
            if (state is ProjectDetailError) {
              return ProjectDetailLoadError(
                message: state.message,
                onRetry: () => context.read<ProjectDetailBloc>().add(
                      LoadProjectDetailEvent(projectId: projectId),
                    ),
              );
            }

            if (state is ProjectDetailLoading || state is ProjectDetailInitial) {
              return ProjectDetailLoadingBody(
                title: initialProjectName,
                onBack: () => popProjectDetailNavigation(
                  context,
                  refreshHomeOnPop: refreshHomeOnPop,
                ),
              );
            }

            if (state is ProjectDetailLoaded) {
              final project = state.project;
              final pendingCount = state.pendingJoinRequestCount;
              final isMemberCompletedView = project.isMemberView &&
                  project.status == ProjectStatus.completed;

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<ProjectDetailBloc>().add(
                        LoadProjectDetailEvent(projectId: projectId),
                      );
                  await context.read<ProjectDetailBloc>().stream.firstWhere(
                        (s) =>
                            s is ProjectDetailLoaded ||
                            s is ProjectDetailError,
                      );
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                  // ── Header ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: PostAuthHeader(
                      title: project.name,
                      leading: AppBackButton(
                        onPressed: () => popProjectDetailNavigation(
                              context,
                              refreshHomeOnPop: refreshHomeOnPop,
                            ),
                      ),
                      trailing: project.showsProjectDetailOverflowMenu
                          ? ProjectDetailTrailingActions(
                              project: project,
                              pendingJoinRequestCount: pendingCount,
                              onLeaderMenuSelected: (action) =>
                                  ProjectDetailNavigationHelpers
                                      .handleLeaderAction(
                                context,
                                project: project,
                                action: action,
                              ),
                              onMemberMenuSelected: (action) =>
                                  ProjectDetailNavigationHelpers
                                      .handleMemberAction(
                                context,
                                project: project,
                                action: action,
                              ),
                            )
                          : null,
                    ),
                  ),

                  // ── Content ─────────────────────────────────────────
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverToBoxAdapter(
                      child: isMemberCompletedView
                          ? ProjectDetailUserCompletedContent(
                              project: project,
                              onMemberTap: (member) {
                                context.push(
                                  AppRoutes.memberDetail,
                                  extra: ProjectDetailNavigationHelpers
                                      .memberDetailArgs(project, member),
                                );
                              },
                            )
                          : Column(
                              children: [
                                SizedBox(height: 12.h),
                                AnnouncementCard(
                                  text: project.announcement,
                                  canDeleteAnnouncement: project.isModeratorView,
                                  onDelete: project.isModeratorView
                                      ? () {
                                          // TODO: delete announcement via BLoC
                                        }
                                      : null,
                                ),
                                SizedBox(height: 12.h),
                                ProjectInfoCard(project: project),
                                SizedBox(height: 16.h),
                                ProjectDetailWalletActions(project: project),
                                SizedBox(height: 20.h),
                                _TabSection(
                                  project: project,
                                  onMemberTap: (member) {
                                    context.push(
                                      AppRoutes.memberDetail,
                                      extra: ProjectDetailNavigationHelpers
                                          .memberDetailArgs(project, member),
                                    );
                                  },
                                ),
                                SizedBox(height: 32.h),
                              ],
                            ),
                    ),
                  ),
                  ],
                ),
              );
            }

            return Center(
              child: AppText(
                AppStrings.errorGeneric,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textBody,
                    ),
              ),
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
    return BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
      builder: (context, state) {
        if (state is! ProjectDetailLoaded) return const SizedBox.shrink();
        final bloc = context.read<ProjectDetailBloc>();
        final isBorrowTab = state.activeTab == ProjectDetailTab.borrowRequests;
        return Column(
          children: [
            AppToggleTabBar(
              outerHeight: AppDimens.projectDetailToggleBarOuterHeight,
              innerTabHeight: AppDimens.projectDetailToggleTabInnerHeight,
              outerBorderRadius: AppDimens.projectDetailToggleBarOuterRadius,
              innerBorderRadius: AppDimens.projectDetailToggleTabInnerRadius,
              labelFontSize: AppDimens.projectDetailToggleLabelFontSize,
              labelFontWeight: FontWeight.w500,
              tabs: [
                AppStrings.tabBorrowRequests,
                project.usesLeaderDetailPanels
                    ? AppStrings.tabManageMembers
                    : AppStrings.tabMember,
              ],
              activeIndex: isBorrowTab ? 0 : 1,
              onTabSelected: (i) => bloc.add(ChangeTabEvent(
                activeTab: i == 0
                    ? ProjectDetailTab.borrowRequests
                    : ProjectDetailTab.members,
              )),
            ),
            SizedBox(height: 16.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: isBorrowTab
                  ? project.usesLeaderDetailPanels
                      ? LeaderBorrowRequestsPanel(
                          key: const ValueKey('leader-borrow'),
                          requests: project.borrowRequests,
                          onViewAll: () => context.push(
                            AppRoutes.borrowRequests,
                            extra: ProjectDetailNavigationHelpers
                                .borrowRequestsArgs(
                              project,
                              isLeaderMode: true,
                            ),
                          ),
                        )
                      : UserBorrowRequestsPanel(
                          key: const ValueKey('user-borrow'),
                          requests: project.borrowRequests,
                          onViewAll: () => context.push(
                            AppRoutes.borrowRequests,
                            extra: ProjectDetailNavigationHelpers
                                .borrowRequestsArgs(
                              project,
                              isLeaderMode: false,
                            ),
                          ),
                        )
                  : project.usesLeaderDetailPanels
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
