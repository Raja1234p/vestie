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
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/announcement_card.dart';
import '../widgets/investment_detail_preview_button.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_completed_detail_content.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_preview_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_trailing_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_load_error.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_loading_body.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_wallet_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';

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
        create: (_) => ServiceLocator.instance.createProjectDetailBloc()
          ..add(LoadProjectDetailEvent(projectId: projectId)),
        child: InvestmentProjectDetailBody(
          projectId: projectId,
          initialProjectName: initialProjectName,
          refreshHomeOnPop: refreshHomeOnPop,
          refreshDiscoverOnPop: refreshDiscoverOnPop,
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
  bool _previewCompletedInvestment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
          builder: (context, state) {
            if (state is ProjectDetailLoading || state is ProjectDetailInitial) {
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
              final isCompleted = project.status == ProjectStatus.completed;
              final showCompletedLayout =
                  isCompleted || _previewCompletedInvestment;

              Future<void> openMemberDetail(MemberEntity member) async {
                final result =
                    await ProjectDetailNavigationHelpers.openMemberProfile(
                  context,
                  project: project,
                  member: member,
                );
                ProjectDetailNavigationHelpers
                    .refreshProjectDetailAfterMemberFlow(
                  context,
                  projectId: widget.projectId,
                  result: result,
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<ProjectDetailBloc>().add(
                        LoadProjectDetailEvent(projectId: widget.projectId),
                      );
                  await context.read<ProjectDetailBloc>().stream.firstWhere(
                        (s) =>
                            s is ProjectDetailLoaded ||
                            s is ProjectDetailError,
                      );
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: PostAuthHeader(
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
                                    ProjectDetailNavigationHelpers
                                        .handleLeaderAction(
                                  context,
                                  project: project,
                                  action: action,
                                ),
                                onMemberMenuSelected: (action) =>
                                    ProjectDetailNavigationHelpers
                                        .handleMemberAction(
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isCompleted)
                              InvestmentDetailPreviewButton(
                                onPressed: () => setState(
                                  () => _previewCompletedInvestment = true,
                                ),
                              ),
                            if (showCompletedLayout)
                              InvestmentCompletedDetailContent(
                                project: project,
                                onMemberTap: (m) => openMemberDetail(m),
                                onDeleteAnnouncement: project
                                        .usesLeaderDetailPanels
                                    ? () {}
                                    : null,
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnnouncementCard(
                                    text: project.announcement,
                                    canDeleteAnnouncement: project.isModeratorView,
                                    onDelete: project.isModeratorView ? () {} : null,
                                  ),
                                  SizedBox(height: 12.h),
                                  ProjectInfoCard(project: project),
                                  SizedBox(height: 16.h),
                                  ProjectDetailWalletActions(project: project),
                                  SizedBox(height: 16.h),
                                  ProjectMembersPreviewSection(
                                    project: project,
                                    onMemberTap: openMemberDetail,
                                    onAddFriend: (member) =>
                                        ProjectDetailNavigationHelpers
                                            .openAddFriendFlow(context, member),
                                  ),
                                  SizedBox(height: 32.h),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Center(child: AppText(AppStrings.errorGeneric));
          },
        ),
      ),
    );
  }
}
