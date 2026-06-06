import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/storage/pending_project_invite_store.dart';
import 'package:vestie/core/widgets/common/app_failure_dialog.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';

import '../cubit/project_invitation_cubit.dart';
import '../cubit/project_invitation_join_effect.dart';
import '../cubit/project_invitation_state.dart';

/// Invite-link join side effects — public → Project Joined; private pending → Request Sent.
class ProjectInvitationJoinListener extends StatelessWidget {
  final Widget child;

  const ProjectInvitationJoinListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectInvitationCubit, ProjectInvitationState>(
      listenWhen: (prev, curr) =>
          curr.joinEffect != null && curr.joinEffect != prev.joinEffect,
      listener: (context, state) async {
        final effect = state.joinEffect;
        if (effect == null) return;

        context.read<ProjectInvitationCubit>().clearJoinEffect();

        switch (effect) {
          case ProjectInvitationJoinShowError(:final message, :final title):
            AppFailureDialog.show(context, title: title, message: message);
          case ProjectInvitationJoinShowRequestSubmitted(
            :final projectId,
            :final projectName,
            :final isInvestment,
          ):
            await PendingProjectInviteStore.clear();
            if (!context.mounted) return;
            openProjectJoinRequestSentSuccess(
              context,
              projectId: projectId,
              projectName: projectName,
              isInvestment: isInvestment,
              fromInviteLink: true,
            );
          case ProjectInvitationJoinOpenDetail(
            :final projectId,
            :final projectName,
            :final isInvestment,
          ):
            await PendingProjectInviteStore.clear();
            if (!context.mounted) return;
            openProjectJoinedSuccess(
              context,
              projectId: projectId,
              projectName: projectName,
              isInvestment: isInvestment,
              fromInviteLink: true,
            );
          case ProjectInvitationJoinNeedsAuth():
            context.go(AppRoutes.login);
        }
      },
      child: child,
    );
  }
}
