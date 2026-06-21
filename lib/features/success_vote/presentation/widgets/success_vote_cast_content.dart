import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';

import '../models/success_vote_cast_choice.dart';
import '../models/success_vote_cast_copy.dart';
import '../models/success_vote_cast_ui_data.dart';
import 'success_vote_cast_actions.dart';
import 'success_vote_cast_scroll_body.dart';

/// Embeddable cast-vote UI for member / co-leader. Parent must wrap in [Expanded].
class SuccessVoteCastContent extends StatefulWidget {
  final SuccessVoteCastUiData data;
  final bool isLoading;
  final Future<bool> Function(bool voteForSuccess)? onSubmitVote;

  const SuccessVoteCastContent({
    super.key,
    required this.data,
    this.isLoading = false,
    this.onSubmitVote,
  });

  @override
  State<SuccessVoteCastContent> createState() => _SuccessVoteCastContentState();
}

class _SuccessVoteCastContentState extends State<SuccessVoteCastContent> {
  SuccessVoteCastChoice _choice = SuccessVoteCastChoice.pending;
  bool _localLoading = false;

  bool get _loading => widget.isLoading || _localLoading;

  SuccessVoteCastCopy get _copy => SuccessVoteCastCopy.forViewer(
        category: widget.data.projectCategory,
        isCoLeader: widget.data.isCoLeader,
      );

  Future<void> _castVote(bool voteForSuccess) async {
    if (_choice != SuccessVoteCastChoice.pending) return;
    final submit = widget.onSubmitVote;
    if (submit != null) {
      setState(() => _localLoading = true);
      final ok = await submit(voteForSuccess);
      if (!mounted) return;
      setState(() => _localLoading = false);
      if (!ok) return;
    }
    setState(() {
      _choice = voteForSuccess
          ? SuccessVoteCastChoice.agreed
          : SuccessVoteCastChoice.disagreed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              choice: _choice,
            ),
          ),
        ),
        FlowScreenFooter(
          child: SuccessVoteCastActions(
            copy: _copy,
            choice: _choice,
            isLoading: _loading,
            onVoteYes: () => _castVote(true),
            onVoteNo: () => _castVote(false),
          ),
        ),
      ],
    );
  }
}

/// @deprecated Use [SuccessVoteCastContent].
typedef MemberSuccessVoteContent = SuccessVoteCastContent;
