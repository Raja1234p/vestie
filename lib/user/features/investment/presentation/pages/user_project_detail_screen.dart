import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_network_avatar.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/widgets/announcement_card.dart';

import '../models/user_investment_ui_snapshot.dart';
import '../widgets/user_project_members_modal.dart';

/// User-facing project detail for investment-style pots (Vacation / Emergency).
class UserProjectDetailScreen extends StatefulWidget {
  final UserInvestmentUiSnapshot snapshot;

  const UserProjectDetailScreen({super.key, required this.snapshot});

  @override
  State<UserProjectDetailScreen> createState() =>
      _UserProjectDetailScreenState();
}

class _UserProjectDetailScreenState extends State<UserProjectDetailScreen> {
  bool _simulatedHasContributed = false;

  UserInvestmentUiSnapshot get _s => widget.snapshot;

  String _fmtUsd(num n) => NumberFormat('#,##0', 'en_US').format(n);

  Future<void> _onMenuSelection(String value) async {
    switch (value) {
      case 'funds':
        context.push(AppRoutes.userInvestmentFundsHistory, extra: _s);
        return;
      case 'members':
        await showUserProjectMembersModal(context, snapshot: _s);
        return;
      case 'leave':
        context.push(
          AppRoutes.leaveProjectWarning,
          extra: LeaveProjectRouteArgs(
            projectId: _s.projectName,
            projectName: _s.projectName,
          ),
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextDate = DateFormat('d MMM yyyy').format(_s.nextContributionDate);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: _s.projectName,
                leading: AppBackButton(onPressed: () => context.pop()),
                trailing: PopupMenuButton<String>(
                  offset: Offset(0, 40.h),
                  onSelected: _onMenuSelection,
                  itemBuilder: (c) => [
                    PopupMenuItem(
                      value: 'funds',
                      child: AppText(AppStrings.userInvestmentMenuFundsHistory),
                    ),
                    PopupMenuItem(
                      value: 'members',
                      child: AppText(AppStrings.userInvestmentMenuViewMembers),
                    ),
                    PopupMenuItem(
                      value: 'leave',
                      child: AppText(
                        AppStrings.userInvestmentMenuLeave,
                        style: GoogleFonts.lato(color: AppColors.error),
                      ),
                    ),
                  ],
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: AppSvgIcon(
                      assetPath: AppAssets.iconMoreOptions,
                      color: AppColors.textPrimary,
                      size: 30.r,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AnnouncementCard(
                    text: _s.announcementOverride,
                    canDeleteAnnouncement: false,
                  ),
                  SizedBox(height: 12.h),
                  _UserInvestmentGoalCard(
                    simulatedHasContributed: _simulatedHasContributed,
                    goalLine: AppStrings.userInvestmentGoalMonthlyAmount(
                      _fmtUsd(_s.monthlyGoalUsd),
                    ),
                    raisedLine: AppStrings.userInvestmentRaisedAmount(
                      _fmtUsd(_s.raisedAfterContributeUsd),
                    ),
                    nextContributionLine:
                        AppStrings.userInvestmentNextContribution(nextDate),
                    onPrimaryPressed: () {
                      if (!_simulatedHasContributed) {
                        setState(() => _simulatedHasContributed = true);
                        return;
                      }
                      context.push(
                        AppRoutes.userInvestmentReturns,
                        extra: InvestmentReturnsRouteArgs(
                          data: InvestmentReturnsUiData.fromLegacySnapshot(_s),
                          isPreview: true,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  AppText(
                    AppStrings.userInvestmentMembersTitle,
                    style: GoogleFonts.lato(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey1100,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (_s.members.isEmpty) _EmptyMembers(),
                ]),
              ),
            ),
            if (_s.members.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _MemberRowTile(member: _s.members[index]),
                    ),
                    childCount: _s.members.length,
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }
}

class _UserInvestmentGoalCard extends StatelessWidget {
  final bool simulatedHasContributed;
  final String goalLine;
  final String raisedLine;
  final String nextContributionLine;
  final VoidCallback onPrimaryPressed;

  const _UserInvestmentGoalCard({
    required this.simulatedHasContributed,
    required this.goalLine,
    required this.raisedLine,
    required this.nextContributionLine,
    required this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.purple300.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            simulatedHasContributed ? raisedLine : goalLine,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (simulatedHasContributed) ...[
            SizedBox(height: 8.h),
            AppText(
              nextContributionLine,
              style: GoogleFonts.lato(
                fontSize: 12.sp,
                color: AppColors.textBody,
              ),
            ),
          ],
          SizedBox(height: 16.h),
          AppButton(
            text: simulatedHasContributed
                ? AppStrings.btnViewMyReturns
                : AppStrings.btnContribute,
            onPressed: onPrimaryPressed,
          ),
        ],
      ),
    );
  }
}

class _MemberRowTile extends StatelessWidget {
  final UserInvestmentMemberUi member;

  const _MemberRowTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          AppNetworkAvatar(
            imageUrl: member.photoUrl,
            initials: member.name.isNotEmpty
                ? member.name[0].toUpperCase()
                : '?',
            size: 52.r,
            backgroundColor: AppColors.purple300.withValues(alpha: 0.4),
            textColor: AppColors.textPrimary,
            fontSize: 18.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText(
              member.name,
              style: GoogleFonts.lato(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (member.isActive)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.badgeCompletedBg,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: AppText(
                AppStrings.userInvestmentMemberActive,
                style: GoogleFonts.lato(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.badgeCompletedText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          AppSvgIcon(
            assetPath: AppAssets.projectMembers,
            size: 40.r,
            color: AppColors.textBody,
          ),
          SizedBox(height: 8.h),
          AppText(
            AppStrings.userInvestmentMembersEmpty,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
