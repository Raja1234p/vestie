import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/app_text.dart';

const _filters = [
  AppStrings.filterAll,
  AppStrings.filterVacations,
  AppStrings.filterEmergency,
  AppStrings.filterInvestments,
];

/// Discover category chips — matches Transaction History [TxFilterBar] styling.
class DiscoverFilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const DiscoverFilterRow({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 10.w),
          ..._filters.map((f) {
            final active = f == selected;
            final iconAsset = _iconAssetForFilter(f);
            return GestureDetector(
              onTap: () => onSelect(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.actionPrimaryPressed
                      : AppColors.chipInactiveBg,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.purple300, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (iconAsset != null) ...[
                      AppSvgIcon(
                        assetPath: iconAsset,
                        size: 14.w,
                        color: active
                            ? AppColors.chipActiveText
                            : AppColors.primary,
                      ),
                      SizedBox(width: 5.w),
                    ],
                    AppText(
                      f,
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: active
                            ? AppColors.chipActiveText
                            : AppColors.chipInactiveText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(width: 10.w),
        ],
      ),
    );
  }
}

String? _iconAssetForFilter(String filter) {
  switch (filter) {
    case AppStrings.filterVacations:
      return AppAssets.projectTypeVacation;
    case AppStrings.filterEmergency:
      return AppAssets.projectTypeEmergency;
    case AppStrings.filterInvestments:
      return AppAssets.projectTypeInvestment;
    default:
      return null;
  }
}
