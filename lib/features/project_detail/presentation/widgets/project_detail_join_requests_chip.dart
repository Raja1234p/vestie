import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Header chip — [join-request.svg] + pending count (Figma, left of ⋯ menu).
class ProjectDetailJoinRequestsChip extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const ProjectDetailJoinRequestsChip({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.purple100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100.r),
        side: const BorderSide(color: AppColors.purple300),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 32.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.iconJoinRequest,
                  width: 20.w,
                  height: 20.h,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                AppText(
                  '$count',
                  style: GoogleFonts.lato(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.projectDetailText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
