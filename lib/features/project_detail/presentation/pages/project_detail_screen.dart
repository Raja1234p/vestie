import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/common/post_auth_scroll_viewport.dart';
import '../../../../core/di/service_locator.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import '../navigation/open_project_from_card.dart';
import '../navigation/project_detail_navigation_helpers.dart';
import '../widgets/project_member_vff_send_actions.dart';
import '../widgets/project_detail_member_layout.dart';
import 'package:vestie/user/features/project_detail/presentation/widgets/project_detail_user_completed_content.dart';
import '../widgets/project_detail_load_error.dart';
import '../widgets/project_detail_loading_body.dart';
import '../widgets/project_detail_moderator_scroll_content.dart';
import '../widgets/project_realtime_scope.dart';

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
        child: ProjectRealtimeScope(
          projectId: projectId,
          child: _ProjectDetailBody(
            projectId: projectId,
            initialProjectName: initialProjectName,
            refreshHomeOnPop: refreshHomeOnPop,
            refreshDiscoverOnPop: refreshDiscoverOnPop,
          ),
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
        child: BlocConsumer<ProjectDetailBloc, ProjectDetailState>(
          listenWhen: (prev, curr) =>
              curr is ProjectDetailLoaded &&
              curr.vffSendErrorMessage != null &&
              curr.vffSendErrorMessage !=
                  (prev is ProjectDetailLoaded ? prev.vffSendErrorMessage : null),
          listener: (context, state) {
            if (state is! ProjectDetailLoaded) return;
            final message = state.vffSendErrorMessage;
            if (message == null || message.isEmpty) return;
            AppSnackBar.showError(context, message);
            context
                .read<ProjectDetailBloc>()
                .add(const ClearMemberVffSendErrorEvent());
          },
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
                return PostAuthScrollViewport(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: onRefresh,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: PostAuthHeader(
                            applyTopSafeArea: false,
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
                              onSendVffRequest: (member) =>
                                  sendMemberVffFromProjectDetail(
                                context,
                                member: member,
                              ),
                              sendingVffUserId: state.sendingVffUserId,
                            ),
                          ),
                        ),
                      ],
                    ),
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

              return ProjectDetailModeratorScrollContent(
                project: project,
                pendingJoinRequestCount: pendingCount,
                refreshHomeOnPop: refreshHomeOnPop,
                refreshDiscoverOnPop: refreshDiscoverOnPop,
                onRefresh: onRefresh,
                onMemberTap: (member) => _openMemberProfile(
                  context,
                  project: project,
                  member: member,
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
  final result = await ProjectDetailNavigationHelpers.openMemberProfile(
    context,
    project: project,
    member: member,
  );
  if (!context.mounted) return;
  ProjectDetailNavigationHelpers.refreshProjectDetailAfterMemberFlow(
    context,
    projectId: project.id,
    result: result,
  );
}
