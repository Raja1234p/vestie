import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

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
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.inter(
            fontSize: 13.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: AppStrings.discoverSearchHint,
          hintStyle: GoogleFonts.inter(
              fontSize: 13.sp, color: AppColors.authHint),
          prefixIcon: Icon(Icons.search_rounded,
              size: 20.w, color: AppColors.authHint),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
}
