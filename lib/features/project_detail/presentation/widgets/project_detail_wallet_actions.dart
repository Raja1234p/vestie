import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/services/risk_disclaimer_gate.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/user/features/contributions/data/models/contribution_submit_result_model.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../navigation/project_detail_navigation_helpers.dart';

/// Contribute (+ Borrow) or [AppStrings.btnViewSuccessVotes] when vote is active.
class ProjectDetailWalletActions extends StatelessWidget {
  final ProjectDetailEntity project;

  /// Dev / API: success vote open — Contribute and Borrow hidden (Figma).
  final bool showViewSuccessVotesCta;

  const ProjectDetailWalletActions({
    super.key,
    required this.project,
    this.showViewSuccessVotesCta = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showViewSuccessVotesCta) {
      return AppButton(
        text: AppStrings.btnViewSuccessVotes,
        onPressed: () => ProjectDetailNavigationHelpers.openLeaderViewSuccessVotes(
          context,
          project: project,
        ),
      );
    }

    final walletArgs = ProjectDetailNavigationHelpers.walletArgs(project);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          text: AppStrings.btnContribute,
          onPressed: () async {
            final accepted = await RiskDisclaimerGate.ensureAccepted(context);
            if (!accepted || !context.mounted) return;
            final result = await context.push<ContributionSubmitResultModel>(
              AppRoutes.contributeFlow,
              extra: walletArgs,
            );
            if (!context.mounted || result == null) return;
            ProjectDetailNavigationHelpers.refreshAfterContribution(
              context,
              projectId: project.id,
              submitResult: result,
            );
          },
        ),
        if (project.showsBorrowAction) ...[
          SizedBox(height: 13.h),
          AppButton(
            text: AppStrings.btnBorrow,
            onPressed: project.canViewerBorrow
                ? () => context.push(
                      AppRoutes.borrowFlow,
                      extra: walletArgs,
                    )
                : null,
            isSecondary: true,
          ),
        ],
      ],
    );
  }
}
