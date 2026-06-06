import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// Reusable "Wallet Balance: $X" pill with optional tap.
class AppWalletPill extends StatelessWidget {
  const AppWalletPill({
    super.key,
    required this.formattedBalance,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  /// Display string with currency, e.g. "2,400" — label + `\$` are prepended.
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
              color: borderColor ?? AppColors.purple300.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: AppText(
              '${AppStrings.walletBalanceLabel} \$$formattedBalance',
              style: GoogleFonts.lato(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey1100,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
