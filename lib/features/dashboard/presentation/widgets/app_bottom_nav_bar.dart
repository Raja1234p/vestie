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
  _NavItem(AppAssets.iconHome,    AppStrings.navHome),
  _NavItem(AppAssets.iconSearch,  AppStrings.navSearch),
  _NavItem(AppAssets.iconAdd,     AppStrings.navAdd),
  _NavItem(AppAssets.iconWallet,  AppStrings.navWallet),
  _NavItem(AppAssets.iconProfile, AppStrings.navProfile),
];

/// Bottom navigation bar.
/// Active state  → solid purple circle, white icon, primary-coloured label.
/// Inactive state → outlined grey circle, muted icon, grey label.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.h,
      decoration: BoxDecoration(
        color: AppColors.navBg,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Circle badge ────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Active: solid purple fill | Inactive: transparent with grey ring
                      color: active ? AppColors.navActive : Colors.transparent,
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppColors.purple900.withValues(alpha: 0.28),
                                blurRadius: 14.r,
                                offset: Offset(0, 4.h),
                              ),
                            ]
                          : null,
                      border: active
                          ? null
                          : Border.all(
                              color: AppColors.grey100, // #E4E0EE
                              width: 1.5,
                            ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        _items[i].asset,
                        width: 24.w,
                        height: 24.w,
                        colorFilter: ColorFilter.mode(
                          active ? Colors.white : AppColors.navInactive,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // ── Label ───────────────────────────────────
                  Text(
                    _items[i].label,
                    style: GoogleFonts.lato(
                      fontSize: 10.sp,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w400,
                      color: active
                          ? AppColors.navActive
                          : AppColors.navInactive,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
