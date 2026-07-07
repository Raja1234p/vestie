import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_announcements_section.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_completed_outcome_extensions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_completed_vote_outcome_content.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_completed_detail_content.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_member_vff_send_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_preview_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_trailing_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_load_error.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_loading_body.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_member_vote_extensions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_inline_member_vote_flow.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_voting_sections.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_wallet_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_reload_scope.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_realtime_scope.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_scroll_insets.dart';

class InvestmentProjectDetailScreen extends StatelessWidget {
  final String projectId;
  final String? initialProjectName;
  final bool refreshHomeOnPop;
  final bool refreshDiscoverOnPop;

  const InvestmentProjectDetailScreen({
    super.key,
    required this.projectId,
    this.initialProjectName,
    this.refreshHomeOnPop = false,
    this.refreshDiscoverOnPop = false,
  });

  @override
  Widget build(BuildContext context) {
    final refreshShellOnPop = refreshHomeOnPop || refreshDiscoverOnPop;
    return PopScope(
      canPop: !refreshShellOnPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !refreshShellOnPop) return;
        popProjectDetailNavigation(
          context,
          refreshHomeOnPop: refreshHomeOnPop,
          refreshDiscoverOnPop: refreshDiscoverOnPop,
        );
      },
      child: BlocProvider(
        create: (_) =>
            ServiceLocator.instance.createProjectDetailBloc()
              ..add(LoadProjectDetailEvent(projectId: projectId)),
        child: ProjectDetailReloadScope(
          projectId: projectId,
          child: ProjectRealtimeScope(
            projectId: projectId,
            child: InvestmentProjectDetailBody(
              projectId: projectId,
              initialProjectName: initialProjectName,
              refreshHomeOnPop: refreshHomeOnPop,
              refreshDiscoverOnPop: refreshDiscoverOnPop,
            ),
          ),
        ),
      ),
    );
  }
}

class InvestmentProjectDetailBody extends StatefulWidget {
  const InvestmentProjectDetailBody({
    super.key,
    required this.projectId,
    required this.initialProjectName,
    required this.refreshHomeOnPop,
    required this.refreshDiscoverOnPop,
  });

  final String projectId;
  final String? initialProjectName;
  final bool refreshHomeOnPop;
  final bool refreshDiscoverOnPop;

  @override
  State<InvestmentProjectDetailBody> createState() =>
      _InvestmentProjectDetailBodyState();
}

class _InvestmentProjectDetailBodyState
    extends State<InvestmentProjectDetailBody> {
  Future<bool> _deleteAnnouncement(String announcementId) async {
    final result = await ServiceLocator.instance
        .deleteProjectAnnouncementUseCase(
          projectId: widget.projectId,
          announcementId: announcementId,
        );
    if (!mounted) return false;
    return result.fold(
      (failure) {
        AppToast.showError(context, FailureMapper.userMessage(failure));
        return false;
      },
      (_) {
        context.read<ProjectDetailBloc>().add(
          LoadProjectDetailEvent(projectId: widget.projectId),
        );
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: BlocConsumer<ProjectDetailBloc, ProjectDetailState>(
          listenWhen: (prev, curr) =>
              curr is ProjectDetailLoaded &&
              curr.vffSendErrorMessage != null &&
              curr.vffSendErrorMessage !=
                  (prev is ProjectDetailLoaded
                      ? prev.vffSendErrorMessage
                      : null),
          listener: (context, state) {
            if (state is! ProjectDetailLoaded) return;
            final message = state.vffSendErrorMessage;
            if (message == null || message.isEmpty) return;
            AppToast.showError(context, message);
            context.read<ProjectDetailBloc>().add(
              const ClearMemberVffSendErrorEvent(),
            );
          },
          builder: (context, state) {
            if (state is ProjectDetailLoading ||
                state is ProjectDetailInitial) {
              return ProjectDetailLoadingBody(
                title: widget.initialProjectName,
                onBack: () => popProjectDetailNavigation(
                  context,
                  refreshHomeOnPop: widget.refreshHomeOnPop,
                  refreshDiscoverOnPop: widget.refreshDiscoverOnPop,
                ),
              );
            }

            if (state is ProjectDetailError) {
              return ProjectDetailLoadError(
                message: state.message,
                onRetry: () => context.read<ProjectDetailBloc>().add(
                  LoadProjectDetailEvent(projectId: widget.projectId),
                ),
              );
            }

            if (state is ProjectDetailLoaded) {
              final project = state.project;
              final pendingCount = state.pendingJoinRequestCount;
              final showCompletedOutcome =
                  project.showsCompletedProjectVoteOutcome;
              final showDistributionLayout =
                  project.showsInvestmentDistributionActions &&
                  !showCompletedOutcome;

              Future<void> refreshDetail() async {
                context.read<ProjectDetailBloc>().add(
                  LoadProjectDetailEvent(projectId: widget.projectId),
                );
                await context.read<ProjectDetailBloc>().stream.firstWhere(
                  (s) => s is ProjectDetailLoaded || s is ProjectDetailError,
                );
              }

              Future<void> openMemberDetail(MemberEntity member) async {
                final result = await ProjectDetailNavigation.openMemberProfile(
                  context,
                  project: project,
                  member: member,
                );
                if (!context.mounted) return;
                ProjectDetailNavigation.refreshProjectDetailAfterMemberFlow(
                  context,
                  projectId: widget.projectId,
                  result: result,
                );
              }

              Widget header() {
                return PostAuthHeader(
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
                          pendingJoinRequestCount: pendingCount,
                          onLeaderMenuSelected: (action) =>
                              ProjectDetailNavigation.handleLeaderAction(
                                context,
                                project: project,
                                action: action,
                                refreshHomeOnPop: widget.refreshHomeOnPop,
                                refreshDiscoverOnPop:
                                    widget.refreshDiscoverOnPop,
                              ),
                          onMemberMenuSelected: (action) =>
                              ProjectDetailNavigation.handleMemberAction(
                                context,
                                project: project,
                                action: action,
                                refreshHomeOnPop: widget.refreshHomeOnPop,
                                refreshDiscoverOnPop:
                                    widget.refreshDiscoverOnPop,
                              ),
                        )
                      : null,
                );
              }

              if (project.showsInlineMemberVoteFlow &&
                  !showDistributionLayout &&
                  !showCompletedOutcome) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header(),
                    Expanded(
                      child: ProjectDetailInlineMemberVoteFlow(
                        project: project,
                        onRefresh: refreshDetail,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header(),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      bottom:
                          ProjectDetailScrollInsets.applyBottomSafeAreaToViewport,
                      child: ColoredBox(
                        color: Colors.white,
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: refreshDetail,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (showCompletedOutcome)
                                        ProjectDetailCompletedVoteOutcomeContent(
                                          project: project,
                                          onMemberTap: (m) => openMemberDetail(m),
                                          onSendVffRequest: (member) =>
                                              sendMemberVffFromProjectDetail(
                                                context,
                                                member: member,
                                              ),
                                          sendingVffUserId: state.sendingVffUserId,
                                          onDeleteAnnouncement:
                                              project.isModeratorView
                                              ? _deleteAnnouncement
                                              : null,
                                        )
                                      else if (showDistributionLayout)
                                        InvestmentCompletedDetailContent(
                                          project: project,
                                          displayAsCompleted: false,
                                          showCompletedNotice: false,
                                          onMemberTap: (m) => openMemberDetail(m),
                                          onSendVffRequest: (member) =>
                                              sendMemberVffFromProjectDetail(
                                                context,
                                                member: member,
                                              ),
                                          sendingVffUserId: state.sendingVffUserId,
                                          onDeleteAnnouncement:
                                              project.isModeratorView
                                              ? _deleteAnnouncement
                                              : null,
                                        )
                                      else ...[
                                        ProjectDetailVotingSections(
                                          project: project,
                                          onRefresh: refreshDetail,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ProjectAnnouncementsSection(
                                              project: project,
                                              onDeleteAnnouncement:
                                                  _deleteAnnouncement,
                                              gapAfter: 12.h,
                                            ),
                                            ProjectInfoCard(project: project),
                                            SizedBox(height: 16.h),
                                            ProjectDetailWalletActions(
                                              project: project,
                                            ),
                                            SizedBox(height: 16.h),
                                            BlocBuilder<
                                              ProjectDetailBloc,
                                              ProjectDetailState
                                            >(
                                              buildWhen: (prev, curr) =>
                                                  prev is ProjectDetailLoaded &&
                                                  curr is ProjectDetailLoaded &&
                                                  (prev.project.members !=
                                                          curr.project.members ||
                                                      prev.sendingVffUserId !=
                                                          curr.sendingVffUserId),
                                              builder: (context, detailState) {
                                                final loaded =
                                                    detailState
                                                        as ProjectDetailLoaded;
                                                return ProjectMembersPreviewSection(
                                                  project: loaded.project,
                                                  onMemberTap: openMemberDetail,
                                                  onSendVffRequest: (member) =>
                                                      sendMemberVffFromProjectDetail(
                                                        context,
                                                        member: member,
                                                      ),
                                                  sendingVffUserId:
                                                      loaded.sendingVffUserId,
                                                );
                                              },
                                            ),
                                            SizedBox(
                                              height:
                                                  ProjectDetailScrollInsets
                                                      .scrollBottomGap(context),
                                            ),
                                          ],
                                        ),
                                      ],
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

            return Center(child: AppText(AppStrings.errorGeneric));
          },
        ),
      ),
    );
  }
}
