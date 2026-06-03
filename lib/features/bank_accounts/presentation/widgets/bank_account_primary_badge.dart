import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Default / primary pill — same styling as payment method cards.
class BankAccountPrimaryBadge extends StatelessWidget {
  const BankAccountPrimaryBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.badgeOnGoingBg,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: AppText(
        AppStrings.cardPrimary,
        style: GoogleFonts.lato(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.badgeOnGoingText,
        ),
      ),
    );
  }
}
