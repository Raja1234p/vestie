import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import 'app_svg_icon.dart';

/// "Wallet: \$2,400" pill for contribute amount / confirm payment rows.
class AppWalletBalanceChip extends StatelessWidget {
  const AppWalletBalanceChip({
    super.key,
    required this.formattedBalance,
    this.minWidth,
    this.backgroundColor,
    this.borderColor,
    this.showChevron = false,
    this.onTap,
  });

  /// Digits with grouping only, e.g. `2,400` — `\$` is prepended in the label.
  final String formattedBalance;

  /// Minimum pill width; grows with text + chevron. Defaults to `140.w`.
  final double? minWidth;

  /// Defaults to [AppColors.searchBarBg] (`#F8F7FA`).
  final Color? backgroundColor;

  final Color? borderColor;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.lato(
      fontSize: 14.sp,
      color: AppColors.neutral1200,
    );

    final textStyle = base.copyWith(height: 1.0);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            style: textStyle,
            children: [
              TextSpan(
                text: 'Wallet: ',
                style: textStyle.copyWith(fontWeight: FontWeight.w400),
              ),
              TextSpan(
                text: '\$$formattedBalance',
                style: textStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
        if (showChevron) ...[
          SizedBox(width: 4.w),
          AppSvgIcon(
            assetPath: AppAssets.iconArrowDown01,
            size: 20.sp,
            color: AppColors.neutral1200,
          ),
        ],
      ],
    );

    final radius = BorderRadius.circular(999.r);
    final decoration = BoxDecoration(
      color: backgroundColor ?? AppColors.searchBarBg,
      borderRadius: radius,
      border: borderColor != null
          ? Border.all(color: borderColor!, width: 1)
          : null,
    );

    final pill = IntrinsicWidth(
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth ?? 140.w),
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: decoration,
        child: Center(child: content),
      ),
    );

    if (onTap == null) return pill;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: pill,
      ),
    );
  }
}
