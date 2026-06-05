import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_navigation_row_tile.dart';
import 'package:vestie/core/widgets/common/leader_action_menu.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_load_error.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_loading_body.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';

/// Storyboard “Project settings” list for primary leaders and co-leaders.
class LeaderProjectSettingsScreen extends StatelessWidget {
  final String projectId;

  const LeaderProjectSettingsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.instance.createProjectDetailBloc()
        ..add(LoadProjectDetailEvent(projectId: projectId)),
      child: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: PostAuthGradientBackground(
              child: state is ProjectDetailLoading ||
                      state is ProjectDetailInitial
                  ? ProjectDetailLoadingBody(
                      onBack: () => context.pop(),
                    )
                  : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: PostAuthHeader(
                      title: AppStrings.leaderProjectSettingsTitle,
                      leading: AppBackButton(onPressed: () => context.pop()),
                    ),
                  ),
                  if (state is ProjectDetailError)
                    SliverFillRemaining(
                      child: ProjectDetailLoadError(
                        message: state.message,
                        onRetry: () => context.read<ProjectDetailBloc>().add(
                              LoadProjectDetailEvent(projectId: projectId),
                            ),
                      ),
                    ),
                  if (state is ProjectDetailLoaded)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
                      sliver: SliverToBoxAdapter(
                        child: _LeaderProjectSettingsBody(
                          project: state.project,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LeaderProjectSettingsBody extends StatelessWidget {
  final ProjectDetailEntity project;

  const _LeaderProjectSettingsBody({required this.project});

  @override
  Widget build(BuildContext context) {
    void onAction(LeaderMenuAction action) {
      ProjectDetailNavigation.handleLeaderAction(
        context,
        project: project,
        action: action,
      );
    }

    final isCoLeader = project.isCoLeader;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppNavigationRowTile(
          title: AppStrings.menuAddAnnouncement,
          onTap: () => onAction(LeaderMenuAction.addAnnouncement),
        ),
        if (!isCoLeader) ...[
          SizedBox(height: 10.h),
          AppNavigationRowTile(
            title: AppStrings.menuEditProject,
            onTap: () => onAction(LeaderMenuAction.editProject),
          ),
        ],
        SizedBox(height: 10.h),
        AppNavigationRowTile(
          title: AppStrings.menuProjectFundsHistory,
          onTap: () => onAction(LeaderMenuAction.projectFundsHistory),
        ),
        if (project.isVacationOrEmergency) ...[
          SizedBox(height: 10.h),
          AppNavigationRowTile(
            title: AppStrings.menuMyBorrows,
            onTap: () => onAction(LeaderMenuAction.myBorrows),
          ),
        ],
        SizedBox(height: 10.h),
        AppNavigationRowTile(
          title: AppStrings.menuInviteMembers,
          onTap: () => onAction(LeaderMenuAction.inviteMembers),
        ),
        if (!isCoLeader && project.canMarkProjectSuccessful) ...[
          SizedBox(height: 10.h),
          AppNavigationRowTile(
            title: AppStrings.menuMarkSuccessful,
            titleColor: AppColors.badgeCompletedText,
            onTap: () => onAction(LeaderMenuAction.markSuccessful),
          ),
        ],
        if (!isCoLeader && project.canStopContributions) ...[
          SizedBox(height: 10.h),
          AppNavigationRowTile(
            title: AppStrings.menuStopContributions,
            titleColor: AppColors.actionStopContributions,
            onTap: () => onAction(LeaderMenuAction.stopContributions),
          ),
        ],
        if (!isCoLeader) ...[
          SizedBox(height: 10.h),
          AppNavigationRowTile(
            title: AppStrings.menuCancelProject,
            titleColor: AppColors.red900,
            onTap: () => onAction(LeaderMenuAction.cancelProject),
          ),
        ],
      ],
    );
  }
}
