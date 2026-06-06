import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/member_success_vote_ui_data.dart';
import 'member_success_vote_actions.dart';
import 'member_success_vote_scroll_body.dart';

/// Embeddable member success-vote UI. Parent must wrap in [Expanded].
///
/// Body scrolls only when content overflows; otherwise it stays pinned to the top.
/// Actions use [Scaffold.bottomNavigationBar].
class MemberSuccessVoteContent extends StatefulWidget {
  final MemberSuccessVoteUiData data;
  final bool isLoading;
  final Future<bool> Function(bool voteForSuccess)? onSubmitVote;

  const MemberSuccessVoteContent({
    super.key,
    required this.data,
    this.isLoading = false,
    this.onSubmitVote,
  });

  @override
  State<MemberSuccessVoteContent> createState() =>
      _MemberSuccessVoteContentState();
}

class _MemberSuccessVoteContentState extends State<MemberSuccessVoteContent> {
  MemberSuccessVoteChoice _choice = MemberSuccessVoteChoice.pending;
  bool _localLoading = false;

  bool get _loading => widget.isLoading || _localLoading;

  Future<void> _castVote(bool voteForSuccess) async {
    if (_choice != MemberSuccessVoteChoice.pending) return;
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
          ? MemberSuccessVoteChoice.agreed
          : MemberSuccessVoteChoice.disagreed;
    });
  }

  Widget _bottomBar() {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 20.h, 0, 15.h),
          child: MemberSuccessVoteActions(
            choice: _choice,
            isLoading: _loading,
            onVoteYes: () => _castVote(true),
            onVoteNo: () => _castVote(false),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MemberSuccessVoteScrollBody(data: widget.data, choice: _choice),
      bottomNavigationBar: _bottomBar(),
    );
  }
}
