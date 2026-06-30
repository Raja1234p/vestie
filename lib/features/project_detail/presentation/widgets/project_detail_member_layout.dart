import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_member_vote_extensions.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_cast_content.dart';

import 'project_detail_cast_vote_dev_previews.dart';
import 'project_detail_inline_member_vote_flow.dart';
import 'project_detail_member_scroll_content.dart';
import 'project_detail_scroll_insets.dart';
import 'project_detail_vote_outcome_dev_previews.dart';
import 'project_detail_trailing_actions.dart';

/// Member project detail — normal scroll or full-height success vote preview.
class ProjectDetailMemberLayout extends StatefulWidget {
  final ProjectDetailEntity project;
  final int pendingJoinRequestCount;
  final bool refreshHomeOnPop;
  final bool refreshDiscoverOnPop;
  final ValueChanged<MemberEntity> onMemberTap;
  final Future<void> Function() onRefresh;

  const ProjectDetailMemberLayout({
    super.key,
    required this.project,
    required this.pendingJoinRequestCount,
    required this.refreshHomeOnPop,
    this.refreshDiscoverOnPop = false,
    required this.onMemberTap,
    required this.onRefresh,
  });

  @override
  State<ProjectDetailMemberLayout> createState() =>
      _ProjectDetailMemberLayoutState();
}

class _ProjectDetailMemberLayoutState extends State<ProjectDetailMemberLayout> {
  bool _previewCastVote = false;

  bool get _canPreviewCastVote =>
      widget.project.showsMemberSuccessVoteDevPreviews &&
      (widget.project.isMemberView || widget.project.isCoLeader);

  Widget _header(BuildContext context) {
    return PostAuthHeader(
      title: widget.project.name,
      leading: AppBackButton(
        onPressed: () => popProjectDetailNavigation(
          context,
          refreshHomeOnPop: widget.refreshHomeOnPop,
          refreshDiscoverOnPop: widget.refreshDiscoverOnPop,
        ),
      ),
      trailing: widget.project.showsProjectDetailOverflowMenu
          ? ProjectDetailTrailingActions(
              project: widget.project,
              pendingJoinRequestCount: widget.pendingJoinRequestCount,
              onLeaderMenuSelected: (action) =>
                  ProjectDetailNavigation.handleLeaderAction(
                    context,
                    project: widget.project,
                    action: action,
                    refreshHomeOnPop: widget.refreshHomeOnPop,
                    refreshDiscoverOnPop: widget.refreshDiscoverOnPop,
                  ),
              onMemberMenuSelected: (action) =>
                  ProjectDetailNavigation.handleMemberAction(
                    context,
                    project: widget.project,
                    action: action,
                    refreshHomeOnPop: widget.refreshHomeOnPop,
                    refreshDiscoverOnPop: widget.refreshDiscoverOnPop,
                  ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_previewCastVote && _canPreviewCastVote) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          Expanded(
            child: SuccessVoteCastContent(
              data: SuccessVoteCastUiData.fromProject(widget.project),
            ),
          ),
        ],
      );
    }

    if (widget.project.showsInlineMemberVoteFlow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          Expanded(
            child: ProjectDetailInlineMemberVoteFlow(
              project: widget.project,
              onRefresh: widget.onRefresh,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(context),
        Expanded(
          child: SafeArea(
            top: false,
            bottom: ProjectDetailScrollInsets.applyBottomSafeAreaToViewport,
            child: ColoredBox(
              color: Colors.white,
              child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: widget.onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_canPreviewCastVote &&
                              !widget.project.votingIsInProgress)
                            ProjectDetailCastVoteDevPreviews(
                              project: widget.project,
                              onPreviewCastVoteInPlace: () =>
                                  setState(() => _previewCastVote = true),
                            ),
                          if (widget.project.showsMemberSuccessVoteDevPreviews &&
                              !widget.project.votingIsInProgress)
                            ProjectDetailVoteOutcomeDevPreviews(
                              project: widget.project,
                            ),
                          ProjectDetailMemberScrollContent(
                            project: widget.project,
                            onMemberTap: widget.onMemberTap,
                            onRefresh: widget.onRefresh,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ],
    );
  }
}
