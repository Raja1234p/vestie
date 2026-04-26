import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class _NavItem {
  final String asset;
  final String label;
  const _NavItem(this.asset, this.label);
}

const _items = [
  _NavItem(AppAssets.iconHome, AppStrings.navHome),
  _NavItem(AppAssets.iconSearch, AppStrings.navSearch),
  _NavItem(AppAssets.iconAdd, AppStrings.navAdd),
  _NavItem(AppAssets.iconWallet, AppStrings.navWallet),
  _NavItem(AppAssets.iconProfile, AppStrings.navProfile),
];

/// Bottom navigation bar: white sheet with rounded bottom corners on [AppColors.dashBg],
/// soft white top edge (no brand tint). Active tab: solid purple circle + white icon,
/// **dark** label. Inactive: light grey circle, [AppColors.grey800] icons, purple label.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static BorderRadius get _barBottomRadius =>
      BorderRadius.vertical(bottom: Radius.circular(28.r));

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.dashBg,
      child: SafeArea(
        top: false,
        child: Container(
          height: 97.h,
          decoration: BoxDecoration(
            color: AppColors.navBg,
            borderRadius: _barBottomRadius,
            border: Border(
              top: BorderSide(color: AppColors.cardBorder, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navBg.withValues(alpha: 0.75),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, -6),
              ),
              BoxShadow(
                color: AppColors.navBg.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? AppColors.navActive
                              : AppColors.neutral200,
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: AppColors.purple900
                                        .withValues(alpha: 0.28),
                                    blurRadius: 14.r,
                                    offset: Offset(0, 4.h),
                                  ),
                                ]
                              : null,
                          border: active
                              ? null
                              : Border.all(
                                  color: AppColors.cardBorder,
                                  width: 1,
                                ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            _items[i].asset,
                            width: 22.w,
                            height: 22.w,
                            colorFilter: ColorFilter.mode(
                              active
                                  ? Colors.white
                                  : AppColors.grey800,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _items[i].label,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                          color: active
                              ? AppColors.grey1100
                              : AppColors.navInactive,
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],
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
