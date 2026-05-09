import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../models/user_vff_profile_ui_model.dart';

/// Two- or three-metric headline row beneath identity.
final class UserVffProfileMetricStrip extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileMetricStrip({super.key, required this.profile});

  Widget _metricCell(String label, String value, double headlineSize) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            style: GoogleFonts.lato(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
          SizedBox(height: 4.h),
          AppText(
            value,
            style: GoogleFonts.lato(
              fontSize: headlineSize.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.grey1100,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final m = p.metrics;

    if (p.metricsLayout == UserVffMetricsLayout.trioCounters &&
        m.projectsDisplay != null) {
      return Row(
        children: [
          _metricCell(
            AppStrings.userVffContributionLabelSingular,
            m.contributionsDisplay,
            16,
          ),
          _metricCell(
            AppStrings.userVffContributed,
            m.contributedDisplay,
            16,
          ),
          _metricCell(
            AppStrings.userVffProjectsLabel,
            m.projectsDisplay!,
            16,
          ),
        ],
      );
    }

    return Row(
      children: [
        _metricCell(AppStrings.userVffContributed, m.contributedDisplay, 17),
        _metricCell(
          AppStrings.userVffContributionsPlural,
          m.contributionsDisplay,
          17,
        ),
      ],
    );
  }
}
