import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

import '../models/success_vote_cast_choice.dart';
import '../models/success_vote_cast_copy.dart';
import '../models/success_vote_cast_ui_data.dart';
import 'success_vote_cast_actions.dart';
import 'success_vote_cast_scroll_body.dart';

/// Embeddable cast-vote UI for member / co-leader. Parent must wrap in [Expanded].
class SuccessVoteCastContent extends StatefulWidget {
  final SuccessVoteCastUiData data;
  final SuccessVoteCastChoice choice;
  final bool canVote;
  final bool? submittingVoteForSuccess;
  final Future<bool> Function(bool voteForSuccess)? onSubmitVote;

  final bool showPerMemberVoteRoster;

  const SuccessVoteCastContent({
    super.key,
    required this.data,
    this.choice = SuccessVoteCastChoice.pending,
    this.canVote = true,
    this.submittingVoteForSuccess,
    this.onSubmitVote,
    this.showPerMemberVoteRoster = false,
  });

  @override
  State<SuccessVoteCastContent> createState() => _SuccessVoteCastContentState();
}

class _SuccessVoteCastContentState extends State<SuccessVoteCastContent> {
  late SuccessVoteCastChoice _choice;
  bool? _localSubmittingVoteForSuccess;

  @override
  void initState() {
    super.initState();
    _choice = widget.choice;
  }

  @override
  void didUpdateWidget(covariant SuccessVoteCastContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.choice != widget.choice) {
      _choice = widget.choice;
    }
    if (oldWidget.submittingVoteForSuccess == null &&
        widget.submittingVoteForSuccess == null) {
      _localSubmittingVoteForSuccess = null;
    }
  }

  bool? get _activeSubmitting =>
      _localSubmittingVoteForSuccess ?? widget.submittingVoteForSuccess;

  bool get _isSubmitting => _activeSubmitting != null;

  SuccessVoteCastCopy get _copy => SuccessVoteCastCopy.forViewer(
    category: widget.data.projectCategory,
    isCoLeader: widget.data.isCoLeader,
    isInvestmentStopContributionsVote:
        widget.data.isInvestmentStopContributionsVote,
    isInvestmentMarkSuccessfulVote: widget.data.isInvestmentMarkSuccessfulVote,
  );

  Future<void> _castVote(bool voteForSuccess) async {
    if (_choice != SuccessVoteCastChoice.pending || !widget.canVote) return;
    if (_isSubmitting) return;
    final submit = widget.onSubmitVote;
    if (submit != null) {
      setState(() => _localSubmittingVoteForSuccess = voteForSuccess);
      final ok = await submit(voteForSuccess);
      if (!mounted) return;
      setState(() => _localSubmittingVoteForSuccess = null);
      if (!ok) return;
    }
    if (widget.onSubmitVote == null) {
      setState(() {
        _choice = voteForSuccess
            ? SuccessVoteCastChoice.agreed
            : SuccessVoteCastChoice.disagreed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final choice = widget.onSubmitVote != null ? widget.choice : _choice;

    return AbsorbPointer(
      absorbing: _isSubmitting,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.p20,
                0,
                AppDimens.p20,
                AppDimens.v16,
              ),
              child: SuccessVoteCastScrollBody(
                data: widget.data,
                copy: _copy,
                choice: choice,
                showPerMemberVoteRoster: widget.showPerMemberVoteRoster,
              ),
            ),
          ),
          FlowScreenFooter(
            child: widget.canVote
                ? SuccessVoteCastActions(
                    copy: _copy,
                    choice: choice,
                    isLoadingYes: _activeSubmitting == true,
                    isLoadingNo: _activeSubmitting == false,
                    onVoteYes: () => _castVote(true),
                    onVoteNo: () => _castVote(false),
                  )
                : _CannotVoteFooter(choice: choice),
          ),
        ],
      ),
    );
  }
}

class _CannotVoteFooter extends StatelessWidget {
  final SuccessVoteCastChoice choice;

  const _CannotVoteFooter({required this.choice});

  @override
  Widget build(BuildContext context) {
    if (choice != SuccessVoteCastChoice.pending) {
      return AppOutlineNeutralButton(
        label: AppStrings.btnBackToHome,
        onPressed: () => context.go(AppRoutes.dashboard),
        borderRadius: AppRadius.r8,
        borderColor: AppColors.backToHomeButtonBorder,
      );
    }

    final theme = Theme.of(context);
    return AppText(
      AppStrings.errorClosureVoteGroupLeaderCannotVote,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.grey1100,
        height: 1.4,
      ),
    );
  }
}

/// @deprecated Use [SuccessVoteCastContent].
typedef MemberSuccessVoteContent = SuccessVoteCastContent;
