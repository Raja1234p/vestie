import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/common/app_invite_members_dashed_divider.dart';
import 'package:vestie/core/widgets/common/app_text.dart';
import 'package:vestie/features/projects/domain/entities/invite_preview_entity.dart';

import '../../domain/invite_preview_category.dart';

String _contributionsDisplay(InvitePreviewEntity preview) {
  if (preview.raisedAmount != null) {
    return AppFormatters.formatWholeAmount(preview.raisedAmount!);
  }
  if (preview.contributionCount != null) {
    return preview.contributionCount!.toString();
  }
  return '—';
}

class ProjectInvitationStatsRow extends StatelessWidget {
  final InvitePreviewEntity preview;
  final bool showTopDivider;

  const ProjectInvitationStatsRow({
    super.key,
    required this.preview,
    this.showTopDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showTopDivider) ...[
          const AppInviteMembersDashedDivider(),
          SizedBox(height: 20.h),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _StatColumn(
              label: AppStrings.projectInvitationProjectType,
              child: _CategoryChip(preview: preview),
            )),
            Expanded(child: _StatColumn(
              label: AppStrings.projectInvitationMembers,
              child: _StatValue(
                preview.memberCount != null
                    ? AppStrings.projectInvitationMembersCount(
                        preview.memberCount!,
                      )
                    : '—',
              ),
            )),
            Expanded(child: _StatColumn(
              label: AppStrings.projectInvitationContributions,
              child: _StatValue(_contributionsDisplay(preview)),
            )),
          ],
        ),
        SizedBox(height: 20.h),
        const AppInviteMembersDashedDivider(),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final Widget child;

  const _StatColumn({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          label,
          style: GoogleFonts.lato(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.grey900,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}

class _StatValue extends StatelessWidget {
  final String text;

  const _StatValue(this.text);

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: GoogleFonts.lato(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral1200,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final InvitePreviewEntity preview;

  const _CategoryChip({required this.preview});

  @override
  Widget build(BuildContext context) {
    final icon = preview.categoryIconAsset;
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.purple100,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.purple300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              SvgPicture.asset(
                icon,
                width: 14.w,
                height: 14.w,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 4.w),
            ],
            AppText(
              preview.categoryChipLabel,
              style: GoogleFonts.lato(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.guidelineTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
