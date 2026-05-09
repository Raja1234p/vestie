import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/storyboard/storyboard_desktop_loader.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/member_project_flow/member_project_header.dart';

import '../models/create_project_fund_draft.dart';
import '../widgets/create_project_members_modal.dart';

/// Storyboard-style project detail view (`create_project_fund_detail_screen`).
class CreateProjectFundDetailScreen extends StatelessWidget {
  final CreateProjectFundDraft draft;

  const CreateProjectFundDetailScreen({
    super.key,
    required this.draft,
  });

  static const List<String> _placeholderMembers = [
    'Alex',
    'Jordan',
    'Riley',
    'Sam',
    'Morgan',
    'Taylor',
  ];

  @override
  Widget build(BuildContext context) {
    final hero = loadStoryboardDesktopImage(draft.kind.suggestedHeroFilename);

    final headerTitle = draft.kind == CreateProjectFundKind.vacation
        ? AppStrings.createProjectVacationFundTitle
        : AppStrings.createProjectEmergencyFundTitle;

    const visibleAvatars = 4;
    final rest = (_placeholderMembers.length - visibleAvatars).clamp(0, 99);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MemberFundFlowHeader(title: headerTitle),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hero != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: AspectRatio(aspectRatio: 16 / 9, child: hero),
                      ),
                      SizedBox(height: 14.h),
                    ],
                    Text(
                      draft.projectName,
                      style: GoogleFonts.lato(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      draft.formattedGoalUsd,
                      style: GoogleFonts.lato(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _WhiteCard(
                      title: AppStrings.detailCardProjectLeader,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26.r,
                            backgroundColor:
                                AppColors.purple300.withValues(alpha: 0.55),
                            child: AppSvgIcon(
                              assetPath: AppAssets.iconPerson,
                              color: AppColors.textPrimary,
                              size: 28.r,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.placeholderLeaderDisplayName,
                                  style: GoogleFonts.lato(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  AppStrings.placeholderLeaderSubtitle,
                                  style: GoogleFonts.lato(
                                    fontSize: 12.sp,
                                    color: AppColors.textBody,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _WhiteCard(
                      title: AppStrings.detailCardDescription,
                      child: Text(
                        draft.description.isEmpty
                            ? AppStrings.summaryPlaceholderDescription
                            : draft.description,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          height: 1.45,
                          color: AppColors.textBody,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _WhiteCard(
                      title: AppStrings.detailCardTimeline,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.timelineStartsOn(
                              draft.formatDate(draft.startDate),
                            ),
                            style: GoogleFonts.lato(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            AppStrings.timelineEndsOn(
                              draft.formatDate(draft.endDate),
                            ),
                            style: GoogleFonts.lato(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppStrings.detailMembersStripTitle,
                          style: GoogleFonts.lato(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showCreateProjectMembersModal(
                            context,
                            _placeholderMembers,
                          ),
                          child: Text(
                            AppStrings.detailMembersViewAll,
                            style: GoogleFonts.lato(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 58.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...List.generate(
                            visibleAvatars < _placeholderMembers.length
                                ? visibleAvatars
                                : _placeholderMembers.length,
                            (i) => Padding(
                              padding: EdgeInsets.only(right: 10.w),
                              child: GestureDetector(
                                onTap: () => showCreateProjectMembersModal(
                                  context,
                                  _placeholderMembers,
                                ),
                                child: CircleAvatar(
                                  radius: 28.r,
                                  backgroundColor:
                                      AppColors.searchBarBg,
                                  child: Text(
                                    _placeholderMembers[i][0],
                                    style: GoogleFonts.lato(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (rest > 0)
                            GestureDetector(
                              onTap: () => showCreateProjectMembersModal(
                                context,
                                _placeholderMembers,
                              ),
                              child: CircleAvatar(
                                radius: 28.r,
                                backgroundColor: AppColors.grey500
                                    .withValues(alpha: 0.35),
                                child: Text(
                                  '+$rest',
                                  style: GoogleFonts.lato(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
                child: AppButton(
                  text: AppStrings.btnContribute,
                  onPressed: () => context.push(
                    AppRoutes.createProjectFundContributionProgress,
                    extra: draft,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _WhiteCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}
