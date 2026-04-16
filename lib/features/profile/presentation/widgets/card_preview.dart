import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_card.dart';

/// Figma-accurate purple gradient card with brand, masked number, primary badge.
class CardPreview extends StatelessWidget {
  final PaymentCard card;
  const CardPreview({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.payCardGradientStart,
            AppColors.payCardGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.payCardGradientStart.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Primary badge ─────────────────────────────
          if (card.isPrimary)
            Positioned(
              top: 0, left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(AppStrings.cardPrimary,
                    style: GoogleFonts.lato(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),

          // ── Masked number ──────────────────────────────
          Positioned(
            bottom: 0, left: 0,
            child: Text(
              card.maskedNumber,
              style: GoogleFonts.lato(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2),
            ),
          ),

          // ── Brand logo ─────────────────────────────────────
          Positioned(
            bottom: 0, right: 0,
            child: SvgPicture.asset(
              card.brand == CardBrand.visa
                  ? AppAssets.iconVisa
                  : AppAssets.iconMastercard,
              width: 44.w,
              height: 28.h,
              colorFilter: const ColorFilter.mode(
                  Colors.white, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}
