import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// Reusable pill-style toggle tab bar with two options.
/// Active tab = dark filled pill. Inactive = outlined.
/// Used in: ProjectDetailScreen, and any future dual-tab views.
class AppToggleTabBar extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  /// Outer grey track height.
  final double? outerHeight;

  /// Inner pill height (vertical inset is derived from outer − inner).
  final double? innerTabHeight;

  /// Outer track corner radius (default pill 100).
  final double? outerBorderRadius;

  /// Inner tab pill corner radius (default pill 100).
  final double? innerBorderRadius;

  final double? labelFontSize;
  final FontWeight? labelFontWeight;
  final Color? activeLabelColor;
  final Color? inactiveLabelColor;

  const AppToggleTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
    this.outerHeight,
    this.innerTabHeight,
    this.outerBorderRadius,
    this.innerBorderRadius,
    this.labelFontSize,
    this.labelFontWeight,
    this.activeLabelColor,
    this.inactiveLabelColor,
  }) : assert(tabs.length == 2, 'AppToggleTabBar supports exactly 2 tabs');

  @override
  Widget build(BuildContext context) {
    final trackHeight = outerHeight ?? 48.h;
    final defaultInset = 5.w;
    final pillHeight =
        innerTabHeight ??
        (trackHeight - defaultInset * 2).clamp(0.0, trackHeight);
    final verticalInset = ((trackHeight - pillHeight) / 2).clamp(
      0.0,
      trackHeight,
    );
    final outerRadius = outerBorderRadius ?? 100.r;
    final innerRadius = innerBorderRadius ?? 100.r;
    final fontSize = labelFontSize ?? 13.sp;
    final fontWeight = labelFontWeight ?? FontWeight.w600;
    final activeColor = activeLabelColor ?? AppColors.neutral100;
    final inactiveColor = inactiveLabelColor ?? AppColors.grey1100;

    return SizedBox(
      height: trackHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(outerRadius),
          border: Border.all(color: AppColors.neutral400),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w, verticalInset, 5.w, verticalInset),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final isActive = i == activeIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    height: pillHeight,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.grey1100 : Colors.transparent,
                      borderRadius: BorderRadius.circular(innerRadius),
                    ),
                    alignment: Alignment.center,
                    child: AppText(
                      tabs[i],
                      style: GoogleFonts.lato(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: isActive ? activeColor : inactiveColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
