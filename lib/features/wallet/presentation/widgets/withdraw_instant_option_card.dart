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

/// Active card stroke — Figma #DDD0FC, 1 logical px (padding ring).
const double _activeBorderWidth = 1;

/// Instant withdraw rail — Figma selected state (#CEBEFB fill, #DDD0FC border, fee footer).
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
        iconAsset: AppAssets.walletWithdrawInstant,
        title: AppStrings.withdrawInstantTitle,
        subtitle: AppStrings.withdrawInstantSubtitle,
        onTap: onTap,
      );
    }

    final radius = BorderRadius.circular(AppRadius.r16);
    final innerRadius =
        BorderRadius.circular(AppRadius.r16 - _activeBorderWidth);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(_activeBorderWidth),
          decoration: BoxDecoration(
            color: AppColors.purple300,
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
          ),
          child: ClipRRect(
            borderRadius: innerRadius,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.purple400,
                  padding: EdgeInsets.all(AppDimens.p14),
                  child: Row(
                    children: [
                      Image.asset(
                        AppAssets.walletWithdrawInstant,
                        width: 64.w,
                        height: 64.w,
                        fit: BoxFit.contain,
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
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey800,
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
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.purple300,
                        width: _activeBorderWidth,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.p14,
                    vertical: AppDimens.v10,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSvgIcon(
                          assetPath: AppAssets.iconInfoCircle,
                          size: AppDimens.iconSmall,
                          color: AppColors.green900,
                        ),
                        SizedBox(width: AppDimens.p8),
                        AppText(
                          AppStrings.withdrawInstantFeeFooter,
                          style: GoogleFonts.lato(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
