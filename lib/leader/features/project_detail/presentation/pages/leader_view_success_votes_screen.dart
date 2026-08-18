import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/leader/features/project_detail/presentation/cubit/leader_view_success_votes_cubit.dart';
import 'package:vestie/leader/features/project_detail/presentation/cubit/leader_view_success_votes_state.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_scroll_insets.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_success_vote/leader_success_vote_majority_banner.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_success_vote/leader_success_vote_member_list.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_success_vote/leader_success_vote_top_section.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_success_vote/leader_view_success_votes_screen_shimmer.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_success_vote/leader_success_vote_tally_cards.dart';

/// Group leader monitors an active success vote (Figma Post-Success — voting window).
class LeaderViewSuccessVotesScreen extends StatelessWidget {
  final LeaderViewSuccessVotesRouteArgs args;

  const LeaderViewSuccessVotesScreen({super.key, required this.args});

  bool get _usesApiLoad =>
      !args.isPreview &&
      args.projectId != null &&
      args.projectId!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_usesApiLoad) {
      return _LeaderViewSuccessVotesShell(
        projectName: args.projectName,
        child: _LeaderViewSuccessVotesContent(data: args.data),
      );
    }

    return BlocProvider(
      create: (_) =>
          ServiceLocator.instance.createLeaderViewSuccessVotesCubit(args)
            ..load(),
      child: BlocListener<LeaderViewSuccessVotesCubit, LeaderViewSuccessVotesState>(
        listenWhen: (prev, curr) =>
            prev.actionErrorMessage != curr.actionErrorMessage &&
            curr.actionErrorMessage != null &&
            curr.actionErrorMessage!.isNotEmpty &&
            !curr.loadFailed,
        listener: (context, state) {
          AppToast.showError(context, state.actionErrorMessage!);
        },
        child: _LeaderViewSuccessVotesProductionBody(args: args),
      ),
    );
  }
}

class _LeaderViewSuccessVotesProductionBody extends StatelessWidget {
  final LeaderViewSuccessVotesRouteArgs args;

  const _LeaderViewSuccessVotesProductionBody({required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderViewSuccessVotesCubit, LeaderViewSuccessVotesState>(
      builder: (context, state) {
        return _LeaderViewSuccessVotesShell(
          projectName: args.projectName,
          child: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LeaderViewSuccessVotesState state) {
    final showsInitialShimmer =
        state.data == null &&
        (state.isLoading ||
            state.loadStatus == LeaderViewSuccessVotesLoadStatus.initial);

    if (showsInitialShimmer) {
      return const LeaderViewSuccessVotesScreenShimmer();
    }

    if (state.loadFailed) {
      return AppErrorView(
        message: state.loadErrorMessage ?? AppStrings.errorGeneric,
        onRetry: () => context.read<LeaderViewSuccessVotesCubit>().load(),
      );
    }

    final data = state.data;
    if (data == null) {
      return AppErrorView(
        message: AppStrings.errorGeneric,
        onRetry: () => context.read<LeaderViewSuccessVotesCubit>().load(),
      );
    }

    return _LeaderViewSuccessVotesContent(
      data: data,
      onRefresh: state.cancelling
          ? null
          : () => context.read<LeaderViewSuccessVotesCubit>().load(),
      continueContribution: data.showContinueContributions
          ? _ContinueContributionFooter(
              label: data.continueContributionLabel,
              isLoading: state.cancelling,
              onConfirm: () =>
                  context.read<LeaderViewSuccessVotesCubit>().continueContributions(),
            )
          : null,
    );
  }
}

class _LeaderViewSuccessVotesShell extends StatelessWidget {
  final String projectName;
  final Widget child;

  const _LeaderViewSuccessVotesShell({
    required this.projectName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthHeader(
              title: projectName,
              leading: AppBackButton(onPressed: () => context.pop()),
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _LeaderViewSuccessVotesContent extends StatelessWidget {
  final LeaderSuccessVoteProgressUiData data;
  final Future<void> Function()? onRefresh;
  final Widget? continueContribution;

  const _LeaderViewSuccessVotesContent({
    required this.data,
    this.onRefresh,
    this.continueContribution,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: continueContribution != null
            ? false
            : ProjectDetailScrollInsets.applyBottomSafeAreaToViewport,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scrollView = SingleChildScrollView(
                    physics: onRefresh != null
                        ? const AlwaysScrollableScrollPhysics()
                        : null,
                    padding: EdgeInsets.only(
                      bottom: ProjectDetailScrollInsets.scrollBottomGap(context),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LeaderSuccessVoteCountdownSection(
                            initialRemaining: data.remaining,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                LeaderSuccessVoteTallyCards(
                                  agreedCount: data.agreedCount,
                                  disagreedCount: data.disagreedCount,
                                  notVotedCount: data.notVotedCount,
                                ),
                                SizedBox(height: 12.h),
                                LeaderSuccessVoteMajorityBanner(
                                  majorityRequired: data.majorityRequired,
                                  totalMembers: data.totalMembers,
                                  isStopContributionsVote:
                                      data.isStopContributionsVote,
                                ),
                                SizedBox(height: 20.h),
                                LeaderSuccessVoteMemberList(members: data.members),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (onRefresh == null) {
                    return scrollView;
                  }

                  return RefreshIndicator(
                    onRefresh: onRefresh!,
                    child: scrollView,
                  );
                },
              ),
            ),
            ?continueContribution,
          ],
        ),
      ),
    );
  }
}

class _ContinueContributionFooter extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Future<bool> Function() onConfirm;

  const _ContinueContributionFooter({
    required this.label,
    required this.isLoading,
    required this.onConfirm,
  });

  Future<void> _onPressed(BuildContext context) async {
    if (isLoading) return;
    final ok = await AppActionDialog.showAsync(
      context,
      title: AppStrings.continueContributionConfirmTitle,
      description: AppStrings.continueContributionConfirmBody,
      primaryLabel: label,
      secondaryLabel: AppStrings.btnNo,
      primaryColor: AppColors.green800,
      onPrimary: onConfirm,
    );
    if (!context.mounted || !ok) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return FlowScreenFooter(
      child: AppButton(
        text: label,
        isLoading: isLoading,
        useGradient: false,
        hasShadow: false,
        color: AppColors.green800,
        onPressed: isLoading ? null : () => _onPressed(context),
      ),
    );
  }
}
