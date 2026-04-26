import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../../../app/router/route_args/project_detail_flow_args.dart';
import 'project_info_card_rows.dart';

/// Banners and stats for [UserSuccessVoteScreen] (no route logic).
class UserSuccessVotePanels extends StatelessWidget {
  final UserSuccessVoteArgs args;

  const UserSuccessVotePanels({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final g = formatProjectInfoAmount(args.goalAmount);
    final r = formatProjectInfoAmount(args.totalRaised);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BannerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                AppStrings.userSuccessVoteBannerTitle,
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey1100,
                ),
              ),
              SizedBox(height: 6.h),
              AppText(
                AppStrings.userSuccessVoteBannerBody,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey800,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _VotingDeadlineCard(
          label: AppStrings.userSuccessVoteDeadlineLabel,
          value:
              '${args.deadlineLabel} (${args.daysRemaining} days remaining)',
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _StatRow(
                label: AppStrings.userSuccessVoteStatGoal,
                value: '\$$g',
              ),
              _divider(),
              _StatRow(
                label: AppStrings.userSuccessVoteStatMembers,
                value: '${args.memberCount}',
              ),
              _divider(),
              _StatRow(
                label: AppStrings.userSuccessVoteTotalRaised,
                value: '\$$r',
                valueColor: AppColors.green800,
                emphasizeValue: true,
                emphasizeLabel: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Widget child;
  const _BannerCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.purple200.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.purple300),
      ),
      child: child,
    );
  }
}

/// Figma: light grey card, **stacked** label (small) + value (larger) — all left-aligned.
class _VotingDeadlineCard extends StatelessWidget {
  final String label;
  final String value;

  const _VotingDeadlineCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
              height: 1.2,
            ),
          ),
          SizedBox(height: 5.h),
          AppText(
            value,
            textAlign: TextAlign.start,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey1100,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasizeValue;
  final bool emphasizeLabel;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasizeValue = false,
    this.emphasizeLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return _SpaceBetweenLabeledValueRow(
      label: label,
      value: value,
      labelStyle: GoogleFonts.lato(
        fontSize: emphasizeLabel ? 15.sp : 13.sp,
        color: AppColors.textBody,
        fontWeight: emphasizeLabel ? FontWeight.w700 : FontWeight.w500,
      ),
      valueStyle: GoogleFonts.lato(
        fontSize: emphasizeValue ? 18.sp : 15.sp,
        fontWeight: FontWeight.w700,
        color: valueColor ?? AppColors.grey1100,
      ),
    );
  }
}

/// Figma: label at leading edge, value at trailing edge (space-between, two columns).
class _SpaceBetweenLabeledValueRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  const _SpaceBetweenLabeledValueRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppText(
            label,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AppText(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

Widget _divider() => Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Divider(height: 1, color: AppColors.divider),
    );
