import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_model.dart';

class UserVffTxRow extends StatelessWidget {
  final UserVffTxRowUi row;

  const UserVffTxRow({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.purple100,
              shape: BoxShape.circle,
            ),
            child: AppSvgIcon(
              assetPath: AppAssets.iconArrowUpBig,
              size: 20.r,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey1100,
                  ),
                ),
                SizedBox(height: 2.h),
                AppText(
                  row.date,
                  style: GoogleFonts.lato(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBody,
                  ),
                ),
              ],
            ),
          ),
          AppText(
            row.amountDisplay,
            style: GoogleFonts.lato(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color:
                  row.positive ? AppColors.txPositive : AppColors.txNegative,
            ),
          ),
        ],
      ),
    );
  }
}
