import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../../utils/project_end_relative_label.dart';
import '../../utils/roi_display_format.dart';
import 'app_svg_icon.dart';

/// Ends-in row with optional trailing ROI (investment cards — Figma).
class ProjectEndAndRoiRow extends StatelessWidget {
  final String endsInRaw;
  final double? roiPercentage;
  final bool showRoi;

  /// Home/discover card (`16.sp`); project detail info card (`13.sp`).
  final bool compact;

  const ProjectEndAndRoiRow({
    super.key,
    required this.endsInRaw,
    this.roiPercentage,
    this.showRoi = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final emphasis = ProjectEndRelativeLabel.emphasis(endsInRaw);
    if (emphasis.isEmpty && (!showRoi || formatRoiPercentDisplay(roiPercentage).isEmpty)) {
      return const SizedBox.shrink();
    }

    final full = ProjectEndRelativeLabel.isFullSentence(endsInRaw);
    final fontSize = compact ? 13.sp : 16.sp;
    const labelColor = AppColors.grey800;
    const valueColor = Color(0xFF000000);

    final labelStyle = GoogleFonts.lato(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: labelColor,
      height: 1.2,
    );
    final valueStyle = GoogleFonts.lato(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: valueColor,
      height: 1.2,
    );

    final roiValue = formatRoiPercentDisplay(roiPercentage);
    final showRoiColumn = showRoi && roiValue.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (emphasis.isNotEmpty)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppSvgIcon(
                  assetPath: AppAssets.iconCalendar02,
                  size: 12,
                  color: labelColor,
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: full
                      ? Text(emphasis, style: valueStyle)
                      : Text.rich(
                          TextSpan(
                            style: labelStyle,
                            children: [
                              TextSpan(text: '${AppStrings.labelEndsIn} '),
                              TextSpan(text: emphasis, style: valueStyle),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          )
        else if (showRoiColumn)
          const Spacer(),
        if (showRoiColumn) ...[
          if (emphasis.isNotEmpty) SizedBox(width: 12.w),
          Text.rich(
            TextSpan(
              style: labelStyle,
              children: [
                TextSpan(text: AppStrings.labelRoiColon),
                TextSpan(text: ' $roiValue', style: valueStyle),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
