import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_types.dart';

class UserVffJoinedProjectRow extends StatelessWidget {
  final UserVffJoinedProjectRowUi row;
  final VoidCallback? onJoin;
  final VoidCallback? onRequestJoin;

  const UserVffJoinedProjectRow({
    super.key,
    required this.row,
    this.onJoin,
    this.onRequestJoin,
  });

  static TextStyle get _actionTextStyle => GoogleFonts.lato(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      );

  Widget _actionChip() {
    switch (row.action) {
      case UserVffJoinedProjectAction.join:
        return _ActionChip(
          label: AppStrings.btnJoin,
          backgroundColor: AppColors.purple700,
          labelColor: AppColors.surface,
          onTap: onJoin,
        );
      case UserVffJoinedProjectAction.requestToJoin:
        return _ActionChip(
          label: AppStrings.userVffRequestToJoin,
          backgroundColor: AppColors.surface,
          labelColor: AppColors.purple700,
          borderColor: AppColors.purple700,
          onTap: onRequestJoin,
        );
      case UserVffJoinedProjectAction.requestSentChip:
        return _ActionChip(
          label: AppStrings.userVffStatusRequestSentSmall,
          backgroundColor: AppColors.purple100,
          labelColor: AppColors.purple700,
        );
      case UserVffJoinedProjectAction.joined:
        return _ActionChip(
          label: AppStrings.userVffJoined,
          backgroundColor: AppColors.purple100,
          labelColor: AppColors.purple700,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
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
            ),
          ),
          SizedBox(width: 8.w),
          _actionChip(),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color labelColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.label,
    required this.backgroundColor,
    required this.labelColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: Text(
        label,
        style: UserVffJoinedProjectRow._actionTextStyle.copyWith(
          color: labelColor,
        ),
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: child,
      ),
    );
  }
}
