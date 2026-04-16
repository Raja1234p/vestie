import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

const _filters = [
  AppStrings.filterAll,
  AppStrings.filterVacations,
  AppStrings.filterEmergency,
  AppStrings.filterInvestments,
];

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
        children: _filters.map((f) {
          final active = f == selected;
          return GestureDetector(
            onTap: () => onSelect(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.chipActiveBg
                    : AppColors.chipInactiveBg,
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: active
                      ? AppColors.chipActiveBg
                      : AppColors.chipBorder,
                ),
              ),
              child: Text(
                f,
                style: GoogleFonts.lato(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? AppColors.chipActiveText
                      : AppColors.chipInactiveText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
