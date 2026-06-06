import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_types.dart';

class UserVffJoinedProjectRow extends StatelessWidget {
  final UserVffJoinedProjectRowUi row;
  final VoidCallback? onCardTap;
  final VoidCallback? onJoin;
  final VoidCallback? onRequestJoin;
  final bool isLoading;

  const UserVffJoinedProjectRow({
    super.key,
    required this.row,
    this.onCardTap,
    this.onJoin,
    this.onRequestJoin,
    this.isLoading = false,
  });

  static TextStyle get _actionTextStyle =>
      GoogleFonts.lato(fontSize: 13.sp, fontWeight: FontWeight.w600);

  Widget _actionChip() {
    switch (row.action) {
      case UserVffJoinedProjectAction.join:
        return _ActionChip(
          label: AppStrings.btnJoin,
          backgroundColor: AppColors.vffJoinedProjectJoinBg,
          labelColor: AppColors.neutral1200,
          onTap: onJoin,
          isLoading: isLoading,
        );
      case UserVffJoinedProjectAction.requestToJoin:
        return _ActionChip(
          label: AppStrings.userVffRequestToJoin,
          backgroundColor: AppColors.vffJoinedProjectRequestBg,
          labelColor: AppColors.neutral1200,
          borderColor: AppColors.vffJoinedProjectRequestBorder,
          onTap: onRequestJoin,
          isLoading: isLoading,
        );
      case UserVffJoinedProjectAction.requestSentChip:
        return _ActionChip(
          label: AppStrings.userVffStatusRequestSentSmall,
          backgroundColor: AppColors.vffRequestSentChipBg,
          labelColor: AppColors.vffRequestSentChipLabel,
          borderColor: AppColors.vffRequestSentChipBorder,
          borderRadius: AppRadius.vffHubRequestActionButton,
        );
      case UserVffJoinedProjectAction.joined:
        return _ActionChip(
          label: AppStrings.userVffJoined,
          backgroundColor: AppColors.purple100,
          labelColor: AppColors.neutral1200,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.vffJoinedProjectCardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.vffJoinedProjectCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _JoinedProjectCardBody(row: row, onTap: onCardTap),
          ),
          SizedBox(width: 8.w),
          _actionChip(),
        ],
      ),
    );
  }
}

class _JoinedProjectCardBody extends StatelessWidget {
  final UserVffJoinedProjectRowUi row;
  final VoidCallback? onTap;

  const _JoinedProjectCardBody({required this.row, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          row.title,
          style: GoogleFonts.lato(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey1100,
          ),
        ),
        SizedBox(height: 2.h),
        AppText(
          '${row.memberCount} ${AppStrings.userVffMembersCountSuffix}',
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey800,
          ),
        ),
      ],
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: content,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color labelColor;
  final Color? borderColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionChip({
    required this.label,
    required this.backgroundColor,
    required this.labelColor,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 8.r;
    final child = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.purple700,
              ),
            )
          : Text(
              label,
              style: UserVffJoinedProjectRow._actionTextStyle.copyWith(
                color: labelColor,
              ),
            ),
    );

    if (onTap == null || isLoading) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}
