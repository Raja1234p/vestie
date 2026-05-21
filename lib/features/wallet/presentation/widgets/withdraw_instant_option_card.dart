import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'withdraw_method_option_card.dart';

/// Instant withdraw rail — Figma selected state (#F5F0FE, gradient border, fee footer).
class WithdrawInstantOptionCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const WithdrawInstantOptionCard({
    super.key,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return WithdrawMethodOptionCard(
        selected: false,
        iconAsset: AppAssets.iconLightning,
        title: AppStrings.withdrawInstantTitle,
        subtitle: AppStrings.withdrawInstantSubtitle,
        onTap: onTap,
      );
    }

    final radius = BorderRadius.circular(AppRadius.r16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.withdrawInstantCardShadow.withValues(
                  alpha: 0.2,
                ),
                blurRadius: 18.6,
                offset: Offset.zero,
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.purple600, AppColors.purple1000],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0.5.w, 0.5.w, 0.5.w, 1.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.purple100,
                    padding: EdgeInsets.all(AppDimens.p14),
                    child: Row(
                      children: [
                        AppSvgIcon(
                          assetPath: AppAssets.iconLightning,
                          size: AppDimens.iconLarge,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppDimens.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                AppStrings.withdrawInstantTitle,
                                style: GoogleFonts.lato(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.grey1100,
                                ),
                              ),
                              SizedBox(height: AppDimens.v4),
                              AppText(
                                AppStrings.withdrawInstantSubtitle,
                                style: GoogleFonts.lato(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: AppColors.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.p14,
                      vertical: AppDimens.v10,
                    ),
                    child: Row(
                      children: [
                        AppSvgIcon(
                          assetPath: AppAssets.iconInformationCircle,
                          size: AppDimens.iconSmall,
                          color: AppColors.green900,
                        ),
                        SizedBox(width: AppDimens.p8),
                        Expanded(
                          child: AppText(
                            AppStrings.withdrawInstantFeeFooter,
                            style: GoogleFonts.lato(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green900,
                            ),
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
      ),
    );
  }
}
