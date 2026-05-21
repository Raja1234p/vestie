import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Centered empty state for payment methods (Figma — illustration + copy only).
class PaymentEmptyView extends StatelessWidget {
  const PaymentEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.paymentMethodsEmptyIllustration,
              width: 240.w,
              height: 200.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            AppText(
              AppStrings.emptyPaymentTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 10.h),
            AppText(
              AppStrings.emptyPaymentSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
