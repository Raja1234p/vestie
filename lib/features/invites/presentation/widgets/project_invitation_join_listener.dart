import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_joined_success_route_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_failure_dialog.dart';
import '../cubit/project_invitation_cubit.dart';
import '../cubit/project_invitation_join_effect.dart';
import '../cubit/project_invitation_state.dart';

/// Invite-link join side effects only — used by [ProjectInvitationScreen].
class ProjectInvitationJoinListener extends StatelessWidget {
  final Widget child;

  const ProjectInvitationJoinListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectInvitationCubit, ProjectInvitationState>(
      listenWhen: (prev, curr) =>
          curr.joinEffect != null && curr.joinEffect != prev.joinEffect,
      listener: (context, state) {
        final effect = state.joinEffect;
        if (effect == null) return;

        context.read<ProjectInvitationCubit>().clearJoinEffect();

        switch (effect) {
          case ProjectInvitationJoinShowError(:final message, :final title):
            AppFailureDialog.show(
              context,
              title: title,
              message: message,
            );
          case ProjectInvitationJoinShowRequestSubmitted():
            AppSnackBar.showSuccess(
              context,
              AppStrings.projectJoinRequestSubmitted,
            );
            context.go(AppRoutes.dashboard);
          case ProjectInvitationJoinOpenDetail(
              :final projectId,
              :final projectName,
              :final isInvestment,
            ):
            // Shared [ProjectJoinedSuccessScreen] → [AppSuccessScreen] (no invite-specific UI).
            context.go(
              AppRoutes.projectJoinedSuccess,
              extra: ProjectJoinedSuccessRouteArgs(
                projectId: projectId,
                projectName: projectName,
                isInvestment: isInvestment,
              ),
            );
          case ProjectInvitationJoinNeedsAuth():
            context.go(AppRoutes.login);
        }
      },
      child: child,
    );
  }
}
