import 'package:flutter/material.dart';
import 'package:vestie/app/router/route_args/project_joined_success_route_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';

/// Immediate join success — same [AppSuccessScreen] defaults as other flows.
final class ProjectJoinedSuccessScreen extends StatelessWidget {
  final ProjectJoinedSuccessRouteArgs args;

  const ProjectJoinedSuccessScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return AppSuccessScreen(
      title: AppStrings.projectJoinedSuccessTitle,
      subtitle: AppStrings.projectJoinedWelcomeSubtitle(args.projectName),
      buttonText: AppStrings.btnOpenProject,
      onButtonPressed: () {
        openProjectDetailAfterJoinSuccess(
          context,
          projectId: args.projectId,
          projectName: args.projectName,
          isInvestment: args.isInvestment,
        );
      },
    );
  }
}
