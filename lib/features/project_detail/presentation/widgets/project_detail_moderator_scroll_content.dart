import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_closure_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_member_vote_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_announcements_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_cast_vote_dev_previews.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_inline_member_vote_flow.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_vote_outcome_dev_previews.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_voting_sections.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_tab_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_preview_section.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_trailing_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_scroll_insets.dart';
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
    final result = await ServiceLocator.instance
        .deleteProjectAnnouncementUseCase(
          projectId: widget.project.id,
          announcementId: announcementId,
        );
    if (!mounted) return false;
    setState(() => _deletingAnnouncement = false);
    return result.fold(
      (failure) {
        AppToast.showError(context, FailureMapper.userMessage(failure));
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
      widget.project.showsViewContributionSuccessVoteAction ||
      widget.project.showsLeaderViewSuccessVotesAction ||
      _previewViewSuccessVotesScenario;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    if (project.showsInlineMemberVoteFlow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PostAuthHeader(
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
                        ProjectDetailNavigation.handleLeaderAction(
                          context,
                          project: project,
                          action: action,
                          refreshHomeOnPop: widget.refreshHomeOnPop,
                          refreshDiscoverOnPop: widget.refreshDiscoverOnPop,
                        ),
                    onMemberMenuSelected: (action) =>
                        ProjectDetailNavigation.handleMemberAction(
                          context,
                          project: project,
                          action: action,
                          refreshHomeOnPop: widget.refreshHomeOnPop,
                          refreshDiscoverOnPop: widget.refreshDiscoverOnPop,
                        ),
                  )
                : null,
          ),
          Expanded(
            child: ProjectDetailInlineMemberVoteFlow(
              project: project,
              onRefresh: widget.onRefresh,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PostAuthHeader(
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
                      ProjectDetailNavigation.handleLeaderAction(
                        context,
                        project: project,
                        action: action,
                        refreshHomeOnPop: widget.refreshHomeOnPop,
                        refreshDiscoverOnPop: widget.refreshDiscoverOnPop,
                      ),
                  onMemberMenuSelected: (action) =>
                      ProjectDetailNavigation.handleMemberAction(
                        context,
                        project: project,
                        action: action,
                        refreshHomeOnPop: widget.refreshHomeOnPop,
                        refreshDiscoverOnPop: widget.refreshDiscoverOnPop,
                      ),
                )
              : null,
        ),
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
                        children: [
                          ProjectDetailVotingSections(
                            project: project,
                            onRefresh: widget.onRefresh,
                          ),
                          SizedBox(height: 12.h),
                          ProjectAnnouncementsSection(
                            project: project,
                            onDeleteAnnouncement: _deleteAnnouncement,
                            gapAfter: 12.h,
                          ),
                          ProjectInfoCard(project: project),
                          if (project.isCoLeader)
                            ProjectDetailCastVoteDevPreviews(project: project),
                          if (project.showsSuccessVoteDevPreviews) ...[
                            ProjectDetailVoteOutcomeDevPreviews(
                              project: project,
                              onPreviewViewSuccessVotesScenario: () =>
                                  setState(
                                    () => _previewViewSuccessVotesScenario =
                                        true,
                                  ),
                            ),
                          ],
                          SizedBox(height: 16.h),
                          ProjectDetailWalletActions(
                            project: project,
                            showViewSuccessVotesCta: _showViewSuccessVotesCta,
                          ),
                          SizedBox(height: 20.h),
                          if (project.showsMembersOnlyLeaderDetailDuringVoting)
                            BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
                              buildWhen: (prev, curr) =>
                                  prev is ProjectDetailLoaded &&
                                  curr is ProjectDetailLoaded &&
                                  (prev.project.members != curr.project.members ||
                                      prev.sendingVffUserId !=
                                          curr.sendingVffUserId),
                              builder: (context, detailState) {
                                if (detailState is! ProjectDetailLoaded) {
                                  return const SizedBox.shrink();
                                }
                                final loaded = detailState;
                                return ProjectMembersPreviewSection(
                                  project: loaded.project,
                                  title: AppStrings.tabManageMembers,
                                  onMemberTap: widget.onMemberTap,
                                  onSendVffRequest: (member) =>
                                      ProjectDetailNavigation
                                          .sendVffRequestFromMemberRow(
                                        context,
                                        member: member,
                                      ),
                                  sendingVffUserId: loaded.sendingVffUserId,
                                );
                              },
                            )
                          else
                            ProjectDetailTabSection(
                              project: project,
                              onMemberTap: widget.onMemberTap,
                            ),
                          SizedBox(
                            height: ProjectDetailScrollInsets.scrollBottomGap(
                              context,
                            ),
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
