import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/services/risk_disclaimer_gate.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/app/router/route_args/project_wallet_flow_args.dart';
import 'package:vestie/user/features/contributions/data/models/contribution_submit_result_model.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../navigation/project_detail_navigation.dart';

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
        onPressed: () => ProjectDetailNavigation.openLeaderViewSuccessVotes(
          context,
          project: project,
        ),
      );
    }

    final walletArgs = ProjectDetailNavigation.walletArgs(project);

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
            ProjectDetailNavigation.refreshAfterContribution(
              context,
              projectId: project.id,
              submitResult: result,
            );
          },
        ),
        if (project.showsBorrowAction) ...[
          SizedBox(height: 13.h),
          _BorrowButton(project: project, walletArgs: walletArgs),
        ],
      ],
    );
  }
}

class _BorrowButton extends StatelessWidget {
  final ProjectDetailEntity project;
  final ProjectWalletFlowArgs walletArgs;

  const _BorrowButton({required this.project, required this.walletArgs});

  @override
  Widget build(BuildContext context) {
    final blocked = project.isBorrowDisabledForViewer;

    return AppButton(
      text: AppStrings.btnBorrow,
      isSecondary: true,
      secondaryFillColor: blocked ? AppColors.grey800 : null,
      secondaryBorderColor: blocked ? AppColors.grey800 : null,
      secondaryLabelColor: blocked ? AppColors.surface : null,
      onPressed: () async {
        if (blocked) {
          AppToast.showInfo(context, AppStrings.borrowRequiresCoLeaderMessage);
          return;
        }
        final submitted = await context.push<bool>(
          AppRoutes.borrowFlow,
          extra: walletArgs,
        );
        if (!context.mounted || submitted != true) return;
        await ProjectDetailNavigation.refreshAfterBorrowSubmit(
          context,
          projectId: project.id,
          reloadDetail: false,
        );
      },
    );
  }
}
