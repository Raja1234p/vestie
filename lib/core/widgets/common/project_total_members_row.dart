import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import 'app_svg_icon.dart';

/// Person icon + "Total Members: N" — home/discover cards and project info card.
class ProjectTotalMembersRow extends StatelessWidget {
  final int count;

  /// Home/discover card (`16.sp`); project detail info card (`13.sp`).
  final bool compact;

  const ProjectTotalMembersRow({
    super.key,
    required this.count,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final fontSize = compact ? 13.sp : 16.sp;
    const labelColor = AppColors.grey800;
    const valueColor = Color(0xFF000000);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppSvgIcon(
          assetPath: AppAssets.iconPerson,
          size: compact ? 12 : 14,
          color: labelColor,
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text.rich(
            TextSpan(
              style: GoogleFonts.lato(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: labelColor,
                height: 1.2,
              ),
              children: [
                TextSpan(text: '${AppStrings.labelTotalMembers}: '),
                TextSpan(
                  text: '$count',
                  style: GoogleFonts.lato(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
