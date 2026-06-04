import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_joined_success_route_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/storage/pending_project_invite_store.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';

/// Join success — shared [AppSuccessScreen] (default hero + layout).
///
/// Pending (private): **Done** → home. Immediate (public): **Open Project** → detail.
final class ProjectJoinedSuccessScreen extends StatelessWidget {
  final ProjectJoinedSuccessRouteArgs args;

  const ProjectJoinedSuccessScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final pending = args.kind == ProjectJoinSuccessKind.requestPending;

    return AppSuccessScreen(
      title: pending
          ? AppStrings.projectJoinRequestSentTitle
          : AppStrings.projectJoinedSuccessTitle,
      subtitle: pending
          ? AppStrings.projectJoinRequestSentSubtitle
          : AppStrings.projectJoinedWelcomeSubtitle(args.projectName),
      buttonText: pending ? AppStrings.btnDone : AppStrings.btnOpenProject,
      onButtonPressed: () => _onPrimaryAction(context, pending: pending),
    );
  }

  Future<void> _onPrimaryAction(
    BuildContext context, {
    required bool pending,
  }) async {
    if (args.fromInviteLink) {
      await PendingProjectInviteStore.clear();
    }
    if (!context.mounted) return;

    if (pending) {
      context.go(AppRoutes.dashboard);
      return;
    }

    openProjectDetailAfterJoinSuccess(
      context,
      projectId: args.projectId,
      projectName: args.projectName,
      isInvestment: args.isInvestment,
    );
  }
}
