import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// “View All …” link on project detail (tab stack or inline section header).
class ProjectDetailViewAllLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  /// In a [Row] beside a section title (e.g. investment Members header).
  final bool inline;

  const ProjectDetailViewAllLink({
    super.key,
    required this.label,
    required this.onTap,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final link = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(bottom: inline ? 0 : 8.h),
        child: AppText(
          label,
          style: GoogleFonts.lato(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral1200,
          ),
        ),
      ),
    );

    if (inline) return link;
    return Align(alignment: Alignment.centerRight, child: link);
  }
}
