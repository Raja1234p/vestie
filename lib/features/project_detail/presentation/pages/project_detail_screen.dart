import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/di/service_locator.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_completed_outcome_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_member_vote_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_inline_member_vote_screen.dart';
import 'package:vestie/features/success_vote/presentation/pages/success_vote_outcome_screen.dart';
import '../navigation/open_project_from_card.dart';
import '../navigation/project_detail_navigation.dart';
import '../widgets/project_detail_member_layout.dart';
import '../widgets/project_detail_load_error.dart';
import '../widgets/project_detail_loading_body.dart';
import '../widgets/project_detail_moderator_scroll_content.dart';
import '../widgets/project_detail_reload_scope.dart';
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
        create: (_) =>
            ServiceLocator.instance.createProjectDetailBloc()
              ..add(LoadProjectDetailEvent(projectId: projectId)),
        child: ProjectDetailReloadScope(
          projectId: projectId,
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
    return BlocConsumer<ProjectDetailBloc, ProjectDetailState>(
      listenWhen: (prev, curr) =>
          curr is ProjectDetailLoaded &&
          curr.vffSendErrorMessage != null &&
          curr.vffSendErrorMessage !=
              (prev is ProjectDetailLoaded ? prev.vffSendErrorMessage : null),
      listener: (context, state) {
        if (state is! ProjectDetailLoaded) return;
        final message = state.vffSendErrorMessage;
        if (message == null || message.isEmpty) return;
        AppToast.showError(context, message);
        context.read<ProjectDetailBloc>().add(
          const ClearMemberVffSendErrorEvent(),
        );
      },
      builder: (context, state) {
        if (state is ProjectDetailLoaded &&
            state.project.showsCompletedProjectVoteOutcome) {
          return SuccessVoteOutcomeScreen(
            args: successVoteOutcomeRouteArgsFromProjectDetail(state.project),
          );
        }

        if (state is ProjectDetailLoaded &&
            state.project.showsInlineMemberVoteFlow) {
          return ProjectDetailInlineMemberVoteScreen(
            project: state.project,
            onBack: () => popProjectDetailNavigation(
              context,
              refreshHomeOnPop: refreshHomeOnPop,
              refreshDiscoverOnPop: refreshDiscoverOnPop,
            ),
            onRefresh: () async {
              context.read<ProjectDetailBloc>().add(
                LoadProjectDetailEvent(projectId: projectId),
              );
              await context.read<ProjectDetailBloc>().stream.firstWhere(
                (s) => s is ProjectDetailLoaded || s is ProjectDetailError,
              );
            },
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: _buildDetailBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildDetailBody(BuildContext context, ProjectDetailState state) {
    return Builder(
      builder: (context) {
            if (state is ProjectDetailError) {
              return ProjectDetailLoadError(
                message: state.message,
                onRetry: () => context.read<ProjectDetailBloc>().add(
                  LoadProjectDetailEvent(projectId: projectId),
                ),
              );
            }

            if (state is ProjectDetailLoading ||
                state is ProjectDetailInitial) {
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

              Future<void> onRefresh() async {
                context.read<ProjectDetailBloc>().add(
                  LoadProjectDetailEvent(projectId: projectId),
                );
                await context.read<ProjectDetailBloc>().stream.firstWhere(
                  (s) => s is ProjectDetailLoaded || s is ProjectDetailError,
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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textBody),
              ),
            );
      },
    );
  }
}

Future<void> _openMemberProfile(
  BuildContext context, {
  required ProjectDetailEntity project,
  required MemberEntity member,
}) async {
  final result = await ProjectDetailNavigation.openMemberProfile(
    context,
    project: project,
    member: member,
  );
  if (!context.mounted) return;
  ProjectDetailNavigation.refreshProjectDetailAfterMemberFlow(
    context,
    projectId: project.id,
    result: result,
  );
}
