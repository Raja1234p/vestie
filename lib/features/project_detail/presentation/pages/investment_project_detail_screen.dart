import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../../home/domain/entities/project.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/entities/project_detail_route_args.dart';
import '../widgets/announcement_card.dart';
import '../widgets/members_list.dart';
import '../widgets/project_info_card.dart';

class InvestmentProjectDetailScreen extends StatelessWidget {
  final ProjectDetailEntity project;

  const InvestmentProjectDetailScreen({super.key, required this.project});

  bool get _isCompleted => project.status == ProjectStatus.completed;

  void _openMemberDetail(BuildContext context, MemberEntity member) {
    context.push(
      AppRoutes.memberDetail,
      extra: MemberDetailRouteArgs(
        member: member,
        projectName: project.name,
        isLeaderView: project.isLeader,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: project.name,
                leading: AppBackButton(
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnnouncementCard(
                      text: project.announcement,
                      isLeader: false,
                    ),
                    SizedBox(height: 12.h),
                    ProjectInfoCard(project: project),
                    SizedBox(height: 16.h),
                    if (!_isCompleted) ...[
                      AppButton(
                        text: AppStrings.btnContribute,
                        onPressed: () => context.push(AppRoutes.transactionAmount),
                      ),
                      SizedBox(height: 16.h),
                    ] else ...[
                      const _NoMoreContributionCard(),
                      SizedBox(height: 16.h),
                    ],
                    AppText(
                      AppStrings.tabMembers,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey1100,
                          ),
                    ),
                    SizedBox(height: 14.h),
                    MembersList(
                      members: project.members,
                      onMemberTap: (member) => _openMemberDetail(context, member),
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

class _NoMoreContributionCard extends StatelessWidget {
  const _NoMoreContributionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.purple200.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20.w,
            color: AppColors.grey800,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  AppStrings.noMoreContributionTitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                      ),
                ),
                SizedBox(height: 4.h),
                AppText(
                  AppStrings.noMoreContributionBody,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                        color: AppColors.grey900,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
