import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/common/post_auth_scroll_viewport.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_announcements_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_success_vote_dev_previews.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_tab_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_trailing_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_wallet_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';

/// Leader / co-leader vacation–emergency detail scroll (Figma).
class ProjectDetailModeratorScrollContent extends StatefulWidget {
  final ProjectDetailEntity project;
  final int pendingJoinRequestCount;
  final bool refreshHomeOnPop;
  final bool refreshDiscoverOnPop;
  final Future<void> Function() onRefresh;
  final ValueChanged<MemberEntity> onMemberTap;

  const ProjectDetailModeratorScrollContent({
    super.key,
    required this.project,
    required this.pendingJoinRequestCount,
    required this.refreshHomeOnPop,
    required this.refreshDiscoverOnPop,
    required this.onRefresh,
    required this.onMemberTap,
  });

  @override
  State<ProjectDetailModeratorScrollContent> createState() =>
      _ProjectDetailModeratorScrollContentState();
}

class _ProjectDetailModeratorScrollContentState
    extends State<ProjectDetailModeratorScrollContent> {
  bool _previewViewSuccessVotesScenario = false;
  bool _deletingAnnouncement = false;

  Future<bool> _deleteAnnouncement(String announcementId) async {
    if (_deletingAnnouncement) return false;
    setState(() => _deletingAnnouncement = true);
    final result =
        await ServiceLocator.instance.deleteProjectAnnouncementUseCase(
      projectId: widget.project.id,
      announcementId: announcementId,
    );
    if (!mounted) return false;
    setState(() => _deletingAnnouncement = false);
    return result.fold(
      (failure) {
        AppSnackBar.showError(context, FailureMapper.userMessage(failure));
        return false;
      },
      (_) {
        widget.onRefresh();
        return true;
      },
    );
  }

  bool get _showViewSuccessVotesCta =>
      widget.project.showsViewSuccessVotesAction ||
      _previewViewSuccessVotesScenario;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return PostAuthScrollViewport(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: PostAuthHeader(
                applyTopSafeArea: false,
                title: project.name,
              leading: AppBackButton(
                onPressed: () => popProjectDetailNavigation(
                  context,
                  refreshHomeOnPop: widget.refreshHomeOnPop,
                  refreshDiscoverOnPop: widget.refreshDiscoverOnPop,
                ),
              ),
              trailing: project.showsProjectDetailOverflowMenu
                  ? ProjectDetailTrailingActions(
                      project: project,
                      pendingJoinRequestCount: widget.pendingJoinRequestCount,
                      onLeaderMenuSelected: (action) =>
                          ProjectDetailNavigationHelpers.handleLeaderAction(
                        context,
                        project: project,
                        action: action,
                      ),
                      onMemberMenuSelected: (action) =>
                          ProjectDetailNavigationHelpers.handleMemberAction(
                        context,
                        project: project,
                        action: action,
                        refreshHomeOnPop: widget.refreshHomeOnPop,
                        refreshDiscoverOnPop: widget.refreshDiscoverOnPop,
                      ),
                    )
                  : null,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  ProjectAnnouncementsSection(
                    project: project,
                    onDeleteAnnouncement: _deleteAnnouncement,
                  ),
                  SizedBox(height: 12.h),
                  ProjectInfoCard(project: project),
                  if (project.showsSuccessVoteDevPreviews) ...[
                    ProjectDetailSuccessVoteDevPreviews(
                      project: project,
                      onPreviewViewSuccessVotesScenario: () => setState(
                        () => _previewViewSuccessVotesScenario = true,
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  ProjectDetailWalletActions(
                    project: project,
                    showViewSuccessVotesCta: _showViewSuccessVotesCta,
                  ),
                  SizedBox(height: 20.h),
                  ProjectDetailTabSection(
                    project: project,
                    onMemberTap: widget.onMemberTap,
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
