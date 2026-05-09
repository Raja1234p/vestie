import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// One selectable rail card on the withdraw-method step.
class WithdrawMethodOptionCard extends StatelessWidget {
  final bool selected;
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const WithdrawMethodOptionCard({
    super.key,
    required this.selected,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.all(AppDimens.p14),
          decoration: BoxDecoration(
            color: selected ? AppColors.purple100 : AppColors.grey100,
            borderRadius: BorderRadius.circular(AppRadius.r16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.neutral400,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AppSvgIcon(
                assetPath: iconAsset,
                size: AppDimens.iconLarge,
                color: AppColors.primary,
              ),
              SizedBox(width: AppDimens.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.grey1100,
                      ),
                    ),
                    SizedBox(height: AppDimens.v4),
                    AppText(
                      subtitle,
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
