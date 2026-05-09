import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/leader_action_menu.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/announcement_card.dart';
import '../widgets/project_detail_user_completed_content.dart';
import 'package:vestie/features/project_detail/presentation/widgets/members_list.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';

class InvestmentProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const InvestmentProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.instance.projectDetailBloc..add(LoadProjectDetailEvent(projectId: projectId)),
      child: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
        builder: (context, state) {
          if (state is ProjectDetailLoading || state is ProjectDetailInitial) {
            return const Scaffold(
              backgroundColor: Colors.transparent,
              body: PostAuthGradientBackground(
                child: ProjectDetailShimmer(),
              ),
            );
          }

          if (state is ProjectDetailError) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: PostAuthGradientBackground(
                child: Center(
                  child: AppText(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textBody,
                        ),
                  ),
                ),
              ),
            );
          }

          if (state is ProjectDetailLoaded) {
            final project = state.project;
            final isCompleted = project.status == ProjectStatus.completed;

            void openMemberDetail(MemberEntity member) {
              context.push(
                AppRoutes.memberDetail,
                extra: ProjectDetailNavigationHelpers.memberDetailArgs(
                  project,
                  member,
                ),
              );
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: PostAuthGradientBackground(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: PostAuthHeader(
                        title: project.name,
                        leading: AppBackButton(onPressed: () => context.pop()),
                        trailing: project.hasManagementPrivileges
                            ? LeaderActionMenu(
                                audience: project.isLeader
                                    ? LeaderMenuAudience.primaryLeader
                                    : LeaderMenuAudience.coLeader,
                                joinRequestCount:
                                    project.pendingJoinRequestCount,
                                onSelected: (action) =>
                                    ProjectDetailNavigationHelpers.handleLeaderAction(
                                  context,
                                  project: project,
                                  action: action,
                              ),
                            )
                            : null,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverToBoxAdapter(
                        child: isCompleted
                            ? ProjectDetailUserCompletedContent(
                                project: project,
                                onMemberTap: (m) => openMemberDetail(m),
                                onDeleteAnnouncement:
                                    project.hasManagementPrivileges ? () {} : null,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnnouncementCard(
                                    text: project.announcement,
                                    isLeader: project.hasManagementPrivileges,
                                    onDelete: () {},
                                  ),
                                  SizedBox(height: 12.h),
                                  ProjectInfoCard(project: project),
                                  SizedBox(height: 16.h),
                                  AppButton(
                                    text: AppStrings.btnContribute,
                                    onPressed: () => context.push(
                                      AppRoutes.contributeFlow,
                                      extra: ProjectDetailNavigationHelpers.walletArgs(project),
                                    ),
                                  ),
                                  SizedBox(height: 13.h),
                                  AppButton(
                                    text: AppStrings.btnBorrow,
                                    onPressed: () => context.push(
                                      AppRoutes.borrowFlow,
                                      extra: ProjectDetailNavigationHelpers.walletArgs(project),
                                    ),
                                    isSecondary: true,
                                  ),
                                  SizedBox(height: 16.h),
                                  AppText(
                                    AppStrings.tabMembers,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.grey1100,
                                        ),
                                  ),
                                  SizedBox(height: 14.h),
                                  MembersList(
                                    members: project.members,
                                    onMemberTap: (m) => openMemberDetail(m),
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

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: PostAuthGradientBackground(
              child: Center(child: AppText(AppStrings.errorGeneric)),
            ),
          );
        },
      ),
    );
  }
}
