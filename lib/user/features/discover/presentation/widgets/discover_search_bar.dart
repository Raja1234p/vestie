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
    final height = 44.h;
    final radius = height / 2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.searchBarBg,
          borderRadius: BorderRadius.circular(radius),
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
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grey800,
            ),
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(16.w, 0, 4.w, 0),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: AppSvgIcon(
                assetPath: AppAssets.iconSearch,
                size: 20.w,
                color: AppColors.purple1000,
              ),
            ),
            suffixIconConstraints: BoxConstraints(
              minWidth: 40.w,
              minHeight: height,
            ),
          ),
        ),
      ),
    );
  }
}
