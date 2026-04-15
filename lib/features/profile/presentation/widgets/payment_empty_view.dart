import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_text.dart';
import 'payment_primary_button.dart';

class PaymentEmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const PaymentEmptyView({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        SvgPicture.asset(
          AppAssets.iconPaymentMethods,
          width: 72.w,
          height: 72.w,
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
        SizedBox(height: 16.h),
        AppText(
          AppStrings.emptyPaymentTitle,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        AppText(
          AppStrings.emptyPaymentSubtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.textBody,
            height: 1.5,
          ),
        ),
        const Spacer(flex: 2),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
          child: PaymentPrimaryButton(
            label: AppStrings.btnAddCard,
            onTap: onAdd,
          ),
        ),
      ],
    );
  }
}
