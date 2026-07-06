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
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/entities/project_detail_closure_extensions.dart';
import '../navigation/project_detail_navigation.dart';
import 'package:vestie/user/features/contributions/data/models/contribution_submit_result_model.dart';

/// Contribute (+ Borrow), [AppStrings.btnViewSuccessVotes],
/// [AppStrings.btnViewContributionSuccessVote], or [AppStrings.btnCastVote].
class ProjectDetailWalletActions extends StatelessWidget {
  final ProjectDetailEntity project;

  /// Leader / co-leader monitor CTA while a closure vote is open.
  final bool showViewSuccessVotesCta;

  const ProjectDetailWalletActions({
    super.key,
    required this.project,
    this.showViewSuccessVotesCta = false,
  });

  bool get _showsLeaderVoteMonitorCta =>
      showViewSuccessVotesCta ||
      project.showsViewContributionSuccessVoteAction ||
      project.showsLeaderViewSuccessVotesAction;

  bool get _showsWalletMoneyActions =>
      !_showsLeaderVoteMonitorCta &&
      !project.showsCastVoteAction &&
      !project.hidesWalletActionsForVoting;

  String get _leaderVoteMonitorButtonLabel =>
      project.showsViewContributionSuccessVoteAction
      ? AppStrings.btnViewContributionSuccessVote
      : AppStrings.btnViewSuccessVotes;

  @override
  Widget build(BuildContext context) {
    if (_showsWalletMoneyActions) {
      return _WalletMoneyActions(project: project);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showsLeaderVoteMonitorCta)
          AppButton(
            text: _leaderVoteMonitorButtonLabel,
            onPressed: () => ProjectDetailNavigation.openLeaderViewSuccessVotes(
              context,
              project: project,
            ),
          ),
        if (_showsLeaderVoteMonitorCta && project.showsCastVoteAction)
          SizedBox(height: 13.h),
        if (project.showsCastVoteAction)
          AppButton(
            text: AppStrings.btnCastVote,
            onPressed: () => ProjectDetailNavigation.openCastVote(
              context,
              project: project,
            ),
          ),
      ],
    );
  }
}

class _WalletMoneyActions extends StatelessWidget {
  final ProjectDetailEntity project;

  const _WalletMoneyActions({required this.project});

  @override
  Widget build(BuildContext context) {
    final walletArgs = ProjectDetailNavigation.walletArgs(project);
    final showContribute = project.showsContributeAction;
    final showBorrow = project.showsBorrowAction;

    if (!showContribute && !showBorrow) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showContribute)
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
              await ProjectDetailNavigation.refreshAfterContribution(
                context,
                projectId: project.id,
                submitResult: result,
              );
            },
          ),
        if (showContribute && showBorrow) SizedBox(height: 13.h),
        if (showBorrow) _BorrowButton(project: project, walletArgs: walletArgs),
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
