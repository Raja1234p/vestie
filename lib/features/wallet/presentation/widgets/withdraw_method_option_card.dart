import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Raster (PNG) vs SVG trailing/leading icon on withdraw-method cards.
bool _isRasterAsset(String path) =>
    path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.jpeg');

/// Active card stroke — Figma #DDD0FC, 1 logical px (padding ring).
const double _activeBorderWidth = 1;

/// One selectable rail card on the withdraw-method step.
class WithdrawMethodOptionCard extends StatelessWidget {
  final bool selected;
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const WithdrawMethodOptionCard({
    super.key,
    required this.selected,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.r16);
    final innerRadius = selected
        ? BorderRadius.circular(AppRadius.r16 - _activeBorderWidth)
        : radius;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: selected
              ? const EdgeInsets.all(_activeBorderWidth)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: selected ? AppColors.purple300 : null,
            borderRadius: radius,
            border: selected
                ? null
                : Border.all(color: AppColors.grey100, width: _activeBorderWidth),
          ),
          child: Container(
            padding: EdgeInsets.all(AppDimens.p14),
            decoration: BoxDecoration(
              color: selected ? AppColors.purple400 : AppColors.grey100,
              borderRadius: innerRadius,
            ),
            child: Row(
              children: [
                _isRasterAsset(iconAsset)
                    ? Image.asset(
                        iconAsset,
                        width: 64.w,
                        height: 64.w,
                        fit: BoxFit.contain,
                      )
                    : AppSvgIcon(
                        assetPath: iconAsset,
                        size: AppDimens.iconLarge,
                        color: AppColors.primary,
                      ),
                SizedBox(width: AppDimens.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        style: GoogleFonts.lato(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grey1100,
                        ),
                      ),
                      SizedBox(height: AppDimens.v4),
                      AppText(
                        subtitle,
                        style: GoogleFonts.lato(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.grey800
                              : AppColors.neutral500,
                        ),
                      ),
                    ],
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
