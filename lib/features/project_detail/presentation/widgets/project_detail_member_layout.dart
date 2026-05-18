import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/user/features/project_detail/presentation/models/member_success_vote_ui_data.dart';
import 'package:vestie/user/features/project_detail/presentation/widgets/member_success_vote_content.dart';

import 'project_detail_member_scroll_content.dart';
import 'project_detail_trailing_actions.dart';

/// Member vacation/emergency detail — normal scroll or full-height success vote.
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
  bool _previewSuccessVote = false;

  bool get _canPreviewSuccessVote => widget.project.isVacationOrEmergency;

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
                  ProjectDetailNavigationHelpers.handleLeaderAction(
                context,
                project: widget.project,
                action: action,
              ),
              onMemberMenuSelected: (action) =>
                  ProjectDetailNavigationHelpers.handleMemberAction(
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

  Widget _previewLink(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        child: AppText(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
        ),
      ),
    );
  }

  Widget _previewButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _previewLink(
          context,
          label: AppStrings.btnPreviewSuccessVote,
          onPressed: () => setState(() => _previewSuccessVote = true),
        ),
        _previewLink(
          context,
          label: AppStrings.btnPreviewVoteOutcomeApproved,
          onPressed: () => ProjectDetailNavigationHelpers.openMemberVoteOutcomePreview(
            context,
            project: widget.project,
            approved: true,
          ),
        ),
        _previewLink(
          context,
          label: AppStrings.btnPreviewVoteOutcomeRejected,
          onPressed: () => ProjectDetailNavigationHelpers.openMemberVoteOutcomePreview(
            context,
            project: widget.project,
            approved: false,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_previewSuccessVote && _canPreviewSuccessVote) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: MemberSuccessVoteContent(
                data: MemberSuccessVoteUiData.fromProject(widget.project),
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _header(context)),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_canPreviewSuccessVote) _previewButtons(context),
                  ProjectDetailMemberScrollContent(
                    project: widget.project,
                    onMemberTap: widget.onMemberTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
