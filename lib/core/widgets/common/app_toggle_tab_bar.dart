import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

/// Reusable pill-style toggle tab bar with two options.
/// Active tab = dark filled pill. Inactive = outlined.
/// Used in: ProjectDetailScreen, and any future dual-tab views.
class AppToggleTabBar extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final double? height;

  const AppToggleTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
    this.height,
  }) : assert(tabs.length == 2, 'AppToggleTabBar supports exactly 2 tabs');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 48.h,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(100.r,),
        border: Border.all(color: AppColors.neutral400)
      ),
      padding: EdgeInsets.all(5.w),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = i == activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.grey1100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[i],
                  style: GoogleFonts.lato(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.neutral100 : AppColors.textBody,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
