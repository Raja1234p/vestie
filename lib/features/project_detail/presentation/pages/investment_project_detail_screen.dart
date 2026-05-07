import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/leader_action_menu.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../../../core/di/service_locator.dart';
import '../../../home/domain/entities/project.dart';
import '../../domain/entities/member_entity.dart';
import '../../../projects/presentation/bloc/project_detail_bloc.dart';
import '../navigation/project_detail_navigation_helpers.dart';
import '../widgets/announcement_card.dart';
import '../widgets/project_detail_user_completed_content.dart';
import '../widgets/members_list.dart';
import '../widgets/project_info_card.dart';

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
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (state is ProjectDetailError) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: PostAuthGradientBackground(
                child: Center(
                  child: Text(
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
                        trailing: project.isLeader
                            ? LeaderActionMenu(
                                joinRequestCount: 3,
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
                                onDeleteAnnouncement: project.isLeader ? () {} : null,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnnouncementCard(
                                    text: project.announcement,
                                    isLeader: project.isLeader,
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
              child: Center(child: Text(AppStrings.errorGeneric)),
            ),
          );
        },
      ),
    );
  }
}
