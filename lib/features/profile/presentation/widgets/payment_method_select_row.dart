import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// One selectable payment row (card or wallet) with Figma radio trailing.
class PaymentMethodSelectRow extends StatelessWidget {
  const PaymentMethodSelectRow({
    super.key,
    required this.selected,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral400),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                leading,
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        style: GoogleFonts.lato(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grey1100,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        AppText(
                          subtitle!,
                          style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppSvgIcon(
                  assetPath: selected
                      ? AppAssets.iconRadioOn
                      : AppAssets.iconRadioOff,
                  size: 22.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Purple circle with white dollar icon (Figma wallet row).
class PaymentMethodWalletIcon extends StatelessWidget {
  const PaymentMethodWalletIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: AppSvgIcon(
        assetPath: AppAssets.iconDollarCircle,
        size: 16.w,
        color: AppColors.surface,
      ),
    );
  }
}
