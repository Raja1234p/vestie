import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
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
                  border: Border.all(
                    color: AppColors.purple300,
                    width: 1,
                  ),
                ),
                child: AppText(
                  f,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: active
                        ? AppColors.chipActiveText
                        : AppColors.chipInactiveText,
                  ),
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
