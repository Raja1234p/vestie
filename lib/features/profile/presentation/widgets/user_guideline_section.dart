import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/profile/domain/entities/user_guideline.dart';

/// Title + body block for a single guideline (Figma).
class UserGuidelineSection extends StatelessWidget {
  const UserGuidelineSection({super.key, required this.item});

  final UserGuideline item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            item.title,
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.guidelineTitle,
              height: 1.25,
            ),
          ),
          SizedBox(height: 12.h),
          AppText(
            item.description,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey800,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
