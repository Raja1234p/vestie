import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_svg_icon.dart';

/// Settings-style navigation row aligned with [ProjectInfoCard]: surface fill,
/// hairline border, 16pt corner radius (Figma / app shell pattern).
class AppNavigationRowTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

  /// When &gt; 0, shows a neutral pill before the chevron (e.g. pending counts).
  final int? badgeCount;
  final bool showChevron;

  const AppNavigationRowTile({
    super.key,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.badgeCount,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = badgeCount != null && badgeCount! > 0;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: titleColor ?? AppColors.grey1100,
                  ),
                ),
              ),
              if (showBadge) ...[
                _AppCountPill(count: badgeCount!),
                SizedBox(width: 8.w),
              ],
              if (showChevron)
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

class _AppCountPill extends StatelessWidget {
  final int count;

  const _AppCountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: AppText(
        '$count',
        style: GoogleFonts.lato(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textBody,
        ),
      ),
    );
  }
}
