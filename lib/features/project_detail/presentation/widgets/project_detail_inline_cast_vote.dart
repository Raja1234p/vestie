import 'package:flutter/material.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/usecases/submit_vote_usecase.dart';
import 'package:vestie/features/project_detail/presentation/mappers/project_detail_voting_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_choice.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_cast_content.dart';

/// Production inline member cast vote on project detail (Week 11+).
///
/// Stays mounted only while [ProjectDetailEntity.showsInlineMemberCastVote] is true.
/// Parent [ProjectDetailBloc] refresh after submit swaps back to the scroll layout.
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
  bool _isSubmitting = false;

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
    if (_isSubmitting || _choice != SuccessVoteCastChoice.pending) {
      return false;
    }
    if (!widget.project.showsInlineMemberCastVote) return false;

    setState(() => _isSubmitting = true);

    final result = await ServiceLocator.instance.submitVoteUseCase(
      SubmitVoteParams(
        projectId: widget.project.id,
        isPositive: voteForSuccess,
      ),
    );

    if (!mounted) return false;

    return result.fold(
      (failure) {
        setState(() => _isSubmitting = false);
        AppToast.showError(context, FailureMapper.userMessage(failure));
        return false;
      },
      (_) async {
        if (!mounted) return false;
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
      canVote: widget.project.showsInlineMemberCastVote &&
          _choice == SuccessVoteCastChoice.pending,
      isLoading: _isSubmitting,
      onSubmitVote: _submitVote,
    );
  }
}
