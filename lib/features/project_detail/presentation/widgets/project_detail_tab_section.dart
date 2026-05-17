import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_toggle_tab_bar.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';

import 'project_detail_tab_panels.dart';

/// Borrow / members toggle below project detail header content.
class ProjectDetailTabSection extends StatelessWidget {
  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity> onMemberTap;

  const ProjectDetailTabSection({
    super.key,
    required this.project,
    required this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
      builder: (context, state) {
        if (state is! ProjectDetailLoaded) return const SizedBox.shrink();
        final bloc = context.read<ProjectDetailBloc>();
        final isBorrowTab = state.activeTab == ProjectDetailTab.borrowRequests;
        return Column(
          children: [
            AppToggleTabBar(
              outerHeight: AppDimens.projectDetailToggleBarOuterHeight,
              innerTabHeight: AppDimens.projectDetailToggleTabInnerHeight,
              outerBorderRadius: AppDimens.projectDetailToggleBarOuterRadius,
              innerBorderRadius: AppDimens.projectDetailToggleTabInnerRadius,
              labelFontSize: AppDimens.projectDetailToggleLabelFontSize,
              labelFontWeight: FontWeight.w500,
              tabs: [
                AppStrings.tabBorrowRequests,
                project.usesLeaderDetailPanels
                    ? AppStrings.tabManageMembers
                    : AppStrings.tabMember,
              ],
              activeIndex: isBorrowTab ? 0 : 1,
              onTabSelected: (i) => bloc.add(ChangeTabEvent(
                activeTab: i == 0
                    ? ProjectDetailTab.borrowRequests
                    : ProjectDetailTab.members,
              )),
            ),
            SizedBox(height: 16.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: isBorrowTab
                  ? project.usesLeaderDetailPanels
                      ? LeaderBorrowRequestsPanel(
                          key: const ValueKey('leader-borrow'),
                          requests: project.borrowRequests,
                          onViewAll: () => context.push(
                            AppRoutes.borrowRequests,
                            extra: ProjectDetailNavigationHelpers
                                .borrowRequestsArgs(
                              project,
                              isLeaderMode: true,
                            ),
                          ),
                        )
                      : UserBorrowRequestsPanel(
                          key: const ValueKey('user-borrow'),
                          requests: project.borrowRequests,
                          onViewAll: () => context.push(
                            AppRoutes.borrowRequests,
                            extra: ProjectDetailNavigationHelpers
                                .borrowRequestsArgs(
                              project,
                              isLeaderMode: false,
                            ),
                          ),
                        )
                  : project.usesLeaderDetailPanels
                      ? LeaderMembersPanel(
                          key: const ValueKey('leader-members'),
                          members: project.members,
                          onMemberTap: project.canReviewMemberProfiles
                              ? onMemberTap
                              : null,
                        )
                      : UserMembersPanel(
                          key: const ValueKey('user-members'),
                          members: project.members,
                          onMemberTap: project.canReviewMemberProfiles
                              ? onMemberTap
                              : null,
                          useFigmaLayout: true,
                        ),
            ),
          ],
        );
      },
    );
  }
}
