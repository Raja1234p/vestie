import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Section label on VFF full-list screens (VFF Requests, Project Invitations).
class UserVffFullListSectionTitle extends StatelessWidget {
  final String title;

  const UserVffFullListSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimens.v16),
      child: AppText(
        title,
        style: GoogleFonts.lato(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral1200,
        ),
      ),
    );
  }
}
