import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_model.dart';

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

  Widget _actionChip(BuildContext context) {
    switch (row.action) {
      case UserVffJoinedProjectAction.join:
        return SizedBox(
          height: 36.h,
          width: 88.w,
          child: AppButton(
            text: AppStrings.btnJoin,
            height: 36.h,
            onPressed: onJoin ?? () {},
          ),
        );
      case UserVffJoinedProjectAction.joined:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.purple100,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: AppColors.purple300),
          ),
          child: AppText(
            AppStrings.userVffJoined,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        );
      case UserVffJoinedProjectAction.requestToJoin:
        return SizedBox(
          height: 36.h,
          width: 120.w,
          child: AppButton(
            text: AppStrings.userVffRequestToJoin,
            height: 36.h,
            isSecondary: true,
            onPressed: onRequestJoin ?? () {},
          ),
        );
      case UserVffJoinedProjectAction.requestSentChip:
        return AppText(
          AppStrings.userVffStatusRequestSentSmall,
          style: GoogleFonts.lato(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textBody,
          ),
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  row.title,
                  style: GoogleFonts.lato(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.grey1100,
                  ),
                ),
                SizedBox(height: 2.h),
                AppText(
                  '${row.memberCount} ${AppStrings.userVffMembersCountSuffix}',
                  style: GoogleFonts.lato(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBody,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _actionChip(context),
        ],
      ),
    );
  }
}
