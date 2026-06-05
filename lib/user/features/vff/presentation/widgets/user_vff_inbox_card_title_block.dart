import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Shared title + subtitle stack for VFF inbox cards.
class UserVffInboxCardTitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final double titleSubtitleGap;

  const UserVffInboxCardTitleBlock({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleSubtitleGap = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          title,
          style: GoogleFonts.lato(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: AppColors.neutral1200,
          ),
        ),
        if (titleSubtitleGap > 0) SizedBox(height: titleSubtitleGap),
        AppText(
          subtitle,
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: AppColors.grey800,
          ),
        ),
      ],
    );
  }
}
