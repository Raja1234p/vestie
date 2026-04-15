import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_text.dart';

class SettingsItem {
  final String svgPath; // asset path for the SVG icon
  final String label;
  final VoidCallback onTap;
  const SettingsItem({
    required this.svgPath,
    required this.label,
    required this.onTap,
  });
}

class SettingsSection extends StatelessWidget {
  final List<SettingsItem> items;
  const SettingsSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.settingsCardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.only(
                  topLeft:     i == 0 ? Radius.circular(16.r) : Radius.zero,
                  topRight:    i == 0 ? Radius.circular(16.r) : Radius.zero,
                  bottomLeft:  isLast ? Radius.circular(16.r) : Radius.zero,
                  bottomRight: isLast ? Radius.circular(16.r) : Radius.zero,
                ),
                onTap: item.onTap,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 17.h),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        item.svgPath,
                        width: 18.w,
                        height: 18.w,
                        colorFilter: ColorFilter.mode(
                            AppColors.textBody, BlendMode.srcIn),
                      ),
                      SizedBox(width: 12.w),
                      AppText(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.cardBorder,
                  indent: 16.w,
                  endIndent: 16.w,
                ),
            ],
          );
        }),
      ),
    );
  }
}
