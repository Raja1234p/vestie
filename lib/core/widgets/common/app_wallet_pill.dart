import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

/// Reusable "Wallet: $X" pill with optional tap (e.g. future payment method picker).
/// Uses [Ink] so the fill is one rounded surface — avoids rectangular [Material] color
/// bleeding past the pill corners.
class AppWalletPill extends StatelessWidget {
  const AppWalletPill({
    super.key,
    required this.formattedBalance,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  /// Display string with currency, e.g. "2,400" — "Wallet: \$" is prepended.
  final String formattedBalance;
  final VoidCallback? onTap;

  /// Defaults to [AppColors.purple100] (lavender pill on gradient / plain bg).
  final Color? backgroundColor;

  /// Defaults to a semi-transparent [AppColors.purple300] stroke.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999.r);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.purple100,
            borderRadius: radius,
            border: Border.all(
              color: borderColor ??
                  AppColors.purple300.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Wallet: \$$formattedBalance',
                  style: GoogleFonts.lato(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey1100,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                  color: AppColors.grey1100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
