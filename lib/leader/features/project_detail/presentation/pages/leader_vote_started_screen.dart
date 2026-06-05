import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';

/// Post-submit confirmation after leader starts stop-contributions vote (Figma).
class LeaderVoteStartedScreen extends StatelessWidget {
  const LeaderVoteStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSuccessScreen(
      illustrationAsset: AppAssets.successProjectCreated,
      title: AppStrings.stopContributionsVoteStartedTitle,
      subtitle: AppStrings.stopContributionsVoteStartedSubtitle,
      buttonText: AppStrings.btnBackToProject,
      onButtonPressed: () => context.pop(),
    );
  }
}
