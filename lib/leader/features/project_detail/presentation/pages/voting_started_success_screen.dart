import 'package:flutter/material.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';

/// Post-submit confirmation after leader starts a closure vote (Figma).
///
/// Used for **Mark as Successful** and **Stop Contributions** after the
/// voting window is submitted.
class VotingStartedSuccessScreen extends StatelessWidget {
  final VotingStartedSuccessRouteArgs args;

  const VotingStartedSuccessScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return AppSuccessScreen(
      illustrationAsset: AppAssets.successProjectCreated,
      title: AppStrings.votingStartedSuccessTitle,
      subtitle: AppStrings.votingStartedSuccessSubtitle,
      buttonText: AppStrings.btnBackToProject,
      onButtonPressed: () => ProjectDetailNavigation.popAfterVoteStarted(
        context,
        projectId: args.projectId,
      ),
    );
  }
}
