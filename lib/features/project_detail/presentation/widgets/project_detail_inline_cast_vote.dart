import 'package:flutter/material.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/usecases/submit_vote_usecase.dart';
import 'package:vestie/features/project_detail/presentation/mappers/project_detail_voting_ui_mappers.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_viewer_penalty_extensions.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_choice.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_cast_content.dart';

/// Production inline member cast vote on project detail (Week 11+).
///
/// Stays mounted only while [ProjectDetailEntity.showsInlineMemberCastVote] is true.
/// After submit, tallies update from the cast response, detail reloads, and the
/// parent swaps to [ProjectDetailInlineVoteSubmitted].
class ProjectDetailInlineCastVote extends StatefulWidget {
  final ProjectDetailEntity project;
  final Future<void> Function() onRefresh;

  const ProjectDetailInlineCastVote({
    super.key,
    required this.project,
    required this.onRefresh,
  });

  @override
  State<ProjectDetailInlineCastVote> createState() =>
      _ProjectDetailInlineCastVoteState();
}

class _ProjectDetailInlineCastVoteState extends State<ProjectDetailInlineCastVote> {
  late SuccessVoteCastUiData _data;
  final SuccessVoteCastChoice _choice = SuccessVoteCastChoice.pending;

  @override
  void initState() {
    super.initState();
    _data = successVoteCastUiDataFromProjectDetail(widget.project);
  }

  @override
  void didUpdateWidget(covariant ProjectDetailInlineCastVote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.id != widget.project.id ||
        oldWidget.project.voting != widget.project.voting ||
        oldWidget.project.activeClosureVote != widget.project.activeClosureVote) {
      _data = successVoteCastUiDataFromProjectDetail(widget.project);
    }
  }

  Future<bool> _submitVote(bool voteForSuccess) async {
    if (_choice != SuccessVoteCastChoice.pending) {
      return false;
    }
    if (!widget.project.viewerCanCastClosureVote) return false;
    if (!widget.project.showsInlineMemberCastVote) return false;

    final result = await ServiceLocator.instance.submitVoteUseCase(
      SubmitVoteParams(
        projectId: widget.project.id,
        isPositive: voteForSuccess,
      ),
    );

    if (!mounted) return false;

    return result.fold(
      (failure) {
        AppToast.showError(context, FailureMapper.userMessage(failure));
        return false;
      },
      (castResult) async {
        if (!mounted) return false;
        setState(() {
          _data = _data.copyWithTallies(
            thumbsUp: castResult.thumbsUp,
            thumbsDown: castResult.thumbsDown,
            notVoted: castResult.notYetVoted,
          );
        });
        await widget.onRefresh();
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SuccessVoteCastContent(
      data: _data,
      choice: _choice,
      canVote: widget.project.viewerCanCastClosureVote &&
          widget.project.showsInlineMemberCastVote &&
          _choice == SuccessVoteCastChoice.pending,
      cannotCastReason: widget.project.closureVoteCastBlockReason,
      onSubmitVote: _submitVote,
    );
  }
}
