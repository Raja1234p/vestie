import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/project_members_empty_illustration.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Figma empty members — gradient disc + person/plus motif.
class ProjectMembersEmptyState extends StatelessWidget {
  /// Full-screen list — vertically centered under the header.
  final bool centered;
  /// Tab preview with "View All" above — less top inset.
  final bool compactTop;

  const ProjectMembersEmptyState({
    super.key,
    this.centered = false,
    this.compactTop = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProjectMembersEmptyIllustration(size: 120.w),
          SizedBox(height: 16.h),
          AppText(
            AppStrings.userInvestmentMembersEmpty,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral1200,
            ),
          ),
      ],
    );

    if (centered) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: content,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24.w,
        compactTop ? 16.h : 32.h,
        24.w,
        compactTop ? 32.h : 48.h,
      ),
      child: content,
    );
  }
}
