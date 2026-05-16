import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/announcement_card.dart';
import '../widgets/project_detail_user_completed_content.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_trailing_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_load_error.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_loading_body.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_wallet_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';

class InvestmentProjectDetailScreen extends StatelessWidget {
  final String projectId;
  final String? initialProjectName;
  final bool refreshHomeOnPop;

  const InvestmentProjectDetailScreen({
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
        child: _InvestmentProjectDetailBody(
          projectId: projectId,
          initialProjectName: initialProjectName,
          refreshHomeOnPop: refreshHomeOnPop,
        ),
      ),
    );
  }
}

class _InvestmentProjectDetailBody extends StatelessWidget {
  const _InvestmentProjectDetailBody({
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
            if (state is ProjectDetailLoading || state is ProjectDetailInitial) {
              return ProjectDetailLoadingBody(
                title: initialProjectName,
                onBack: () => popProjectDetailNavigation(
                  context,
                  refreshHomeOnPop: refreshHomeOnPop,
                ),
              );
            }

            if (state is ProjectDetailError) {
              return ProjectDetailLoadError(
                message: state.message,
                onRetry: () => context.read<ProjectDetailBloc>().add(
                      LoadProjectDetailEvent(projectId: projectId),
                    ),
              );
            }

            if (state is ProjectDetailLoaded) {
              final project = state.project;
              final pendingCount = state.pendingJoinRequestCount;
              final isCompleted = project.status == ProjectStatus.completed;

              void openMemberDetail(MemberEntity member) {
                context.push(
                  AppRoutes.memberDetail,
                  extra: ProjectDetailNavigationHelpers.memberDetailArgs(
                    project,
                    member,
                  ),
                );
              }

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
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverToBoxAdapter(
                        child: isCompleted
                            ? ProjectDetailUserCompletedContent(
                                project: project,
                                onMemberTap: (m) => openMemberDetail(m),
                                onDeleteAnnouncement:
                                    project.usesLeaderDetailPanels ? () {} : null,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnnouncementCard(
                                    text: project.announcement,
                                    canDeleteAnnouncement: project.isModeratorView,
                                    onDelete: project.isModeratorView ? () {} : null,
                                  ),
                                  SizedBox(height: 12.h),
                                  ProjectInfoCard(project: project),
                                  SizedBox(height: 16.h),
                                  ProjectDetailWalletActions(project: project),
                                  SizedBox(height: 16.h),
                                  ProjectMembersSection(
                                    title: AppStrings.tabMembers,
                                    members: project.members,
                                    onMemberTap: openMemberDetail,
                                    onAddFriend: (member) =>
                                        ProjectDetailNavigationHelpers
                                            .openAddFriendFlow(context, member),
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

            return Center(child: AppText(AppStrings.errorGeneric));
          },
        ),
      ),
    );
  }
}
