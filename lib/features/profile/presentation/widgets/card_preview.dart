import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';

/// Figma card detail preview — 370×175 white surface, noise, masked number, brand.
class CardPreview extends StatelessWidget {
  final PaymentCard card;
  const CardPreview({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 175.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.r12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppAssets.paymentCardBgBase,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            Image.asset(
              AppAssets.paymentCardBgOverlay,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Stack(
                children: [
                  if (card.isPrimary)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.payCardPrimaryBadge,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Text(
                          AppStrings.cardPrimary,
                          style: GoogleFonts.lato(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      card.maskedNumber,
                      style: GoogleFonts.lato(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.grey1100,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: SvgPicture.asset(
                        card.brand == CardBrand.visa
                            ? AppAssets.iconVisa
                            : AppAssets.iconMastercard,
                        width: 40.w,
                        height: 14.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
