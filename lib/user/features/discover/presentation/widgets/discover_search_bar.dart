import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';

class DiscoverSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const DiscoverSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.inputFieldBorder),
      ),
      child: TextField(
        onChanged: onChanged,
        onTapOutside: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style: GoogleFonts.lato(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.inputFieldText,
        ),
        decoration: InputDecoration(
          hintText: AppStrings.discoverSearchHint,
          hintStyle: GoogleFonts.lato(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.authHint,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 12.w, right: 8.w),
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: AppSvgIcon(
                assetPath: AppAssets.iconSearch,
                size: 20.w,
                color: AppColors.inputFieldIcon,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
}
