import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/di/service_locator.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import '../navigation/open_project_from_card.dart';
import '../navigation/project_detail_navigation_helpers.dart';
import '../widgets/announcement_card.dart';
import '../widgets/project_detail_member_layout.dart';
import '../widgets/project_detail_tab_section.dart';
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
  final bool refreshDiscoverOnPop;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.initialProjectName,
    this.refreshHomeOnPop = false,
    this.refreshDiscoverOnPop = false,
  });

  @override
  Widget build(BuildContext context) {
    final refreshShellOnPop = refreshHomeOnPop || refreshDiscoverOnPop;
    return PopScope(
      canPop: !refreshShellOnPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !refreshShellOnPop) return;
        popProjectDetailNavigation(
          context,
          refreshHomeOnPop: refreshHomeOnPop,
          refreshDiscoverOnPop: refreshDiscoverOnPop,
        );
      },
      child: BlocProvider(
        create: (_) => ServiceLocator.instance.createProjectDetailBloc()
          ..add(LoadProjectDetailEvent(projectId: projectId)),
        child: _ProjectDetailBody(
          projectId: projectId,
          initialProjectName: initialProjectName,
          refreshHomeOnPop: refreshHomeOnPop,
          refreshDiscoverOnPop: refreshDiscoverOnPop,
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
    required this.refreshDiscoverOnPop,
  });

  final String projectId;
  final String? initialProjectName;
  final bool refreshHomeOnPop;
  final bool refreshDiscoverOnPop;

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
                  refreshDiscoverOnPop: refreshDiscoverOnPop,
                ),
              );
            }

            if (state is ProjectDetailLoaded) {
              final project = state.project;
              final pendingCount = state.pendingJoinRequestCount;
              final isMemberCompletedView = project.isMemberView &&
                  project.status == ProjectStatus.completed;

              Future<void> onRefresh() async {
                context.read<ProjectDetailBloc>().add(
                      LoadProjectDetailEvent(projectId: projectId),
                    );
                await context.read<ProjectDetailBloc>().stream.firstWhere(
                      (s) =>
                          s is ProjectDetailLoaded || s is ProjectDetailError,
                    );
              }

              if (isMemberCompletedView) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: onRefresh,
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
                              refreshDiscoverOnPop: refreshDiscoverOnPop,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverToBoxAdapter(
                          child: ProjectDetailUserCompletedContent(
                            project: project,
                            onMemberTap: (member) => _openMemberProfile(
                              context,
                              project: project,
                              member: member,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (project.isMemberView) {
                return ProjectDetailMemberLayout(
                  project: project,
                  pendingJoinRequestCount: pendingCount,
                  refreshHomeOnPop: refreshHomeOnPop,
                  refreshDiscoverOnPop: refreshDiscoverOnPop,
                  onMemberTap: (member) => _openMemberProfile(
                    context,
                    project: project,
                    member: member,
                  ),
                  onRefresh: onRefresh,
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: onRefresh,
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
                            refreshDiscoverOnPop: refreshDiscoverOnPop,
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
                                  refreshHomeOnPop: refreshHomeOnPop,
                                  refreshDiscoverOnPop: refreshDiscoverOnPop,
                                ),
                              )
                            : null,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverToBoxAdapter(
                        child: Column(
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
                            ProjectDetailTabSection(
                              project: project,
                              onMemberTap: (member) => _openMemberProfile(
                                context,
                                project: project,
                                member: member,
                              ),
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

Future<void> _openMemberProfile(
  BuildContext context, {
  required ProjectDetailEntity project,
  required MemberEntity member,
}) async {
  final refreshed = await ProjectDetailNavigationHelpers.openMemberProfile(
    context,
    project: project,
    member: member,
  );
  if (refreshed == true && context.mounted) {
    context.read<ProjectDetailBloc>().add(
          LoadProjectDetailEvent(projectId: project.id),
        );
  }
}
