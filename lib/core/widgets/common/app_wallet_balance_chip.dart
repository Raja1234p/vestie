import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';

/// "Wallet Balance: \$2,400" pill for contribute amount / confirm payment rows.
class AppWalletBalanceChip extends StatelessWidget {
  const AppWalletBalanceChip({
    super.key,
    required this.formattedBalance,
    this.minWidth,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  /// Digits with grouping only, e.g. `2,400` — `\$` is prepended after the label.
  final String formattedBalance;

  /// Minimum pill width; grows with text. Defaults to `140.w`.
  final double? minWidth;

  /// Defaults to [AppColors.searchBarBg] (`#F8F7FA`).
  final Color? backgroundColor;

  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.lato(
      fontSize: 14.sp,
      color: AppColors.neutral1200,
    );

    final textStyle = base.copyWith(height: 1.0);
    final content = Text.rich(
      TextSpan(
        style: textStyle,
        children: [
          TextSpan(
            text: '${AppStrings.walletBalanceLabel} ',
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
      child: InkWell(onTap: onTap, borderRadius: radius, child: pill),
    );
  }
}
