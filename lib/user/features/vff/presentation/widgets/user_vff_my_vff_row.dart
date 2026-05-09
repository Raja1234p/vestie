import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_avatar_circle.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_hub_ui_model.dart';

/// **Flow: Hub → “My VFFs” tab** — one verified connection row.
class UserVffMyVffRow extends StatelessWidget {
  final UserVffConnectionRowUi row;
  final VoidCallback onOpen;

  const UserVffMyVffRow({
    super.key,
    required this.row,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onOpen,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppAvatarCircle(
                initials: row.initials,
                size: 48.r,
                backgroundColor: AppColors.purple200,
                textColor: AppColors.grey1100,
                fontSize: 13.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      row.name,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.grey1100,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AppText(
                      row.mutualLabel,
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              if (row.isPendingSent)
                AppText(
                  AppStrings.userVffStatusRequestSentSmall,
                  style: GoogleFonts.lato(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBody,
                  ),
                )
              else
                AppSvgIcon(
                  assetPath: AppAssets.iconChevronRight,
                  color: AppColors.grey800,
                  size: 24.r,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
