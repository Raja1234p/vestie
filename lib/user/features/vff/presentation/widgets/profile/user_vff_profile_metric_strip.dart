import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import '../../models/user_vff_profile_ui_model.dart';
import 'user_vff_profile_metric_card.dart';

/// Contributions / Projects metrics beneath identity (public profile).
final class UserVffProfileMetricStrip extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileMetricStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final m = p.metrics;

    if (p.metricsLayout == UserVffMetricsLayout.trioCounters &&
        m.projectsDisplay != null) {
      return Row(
        children: [
          UserVffProfileMetricCard(
            label: AppStrings.userVffContributionLabelSingular,
            value: m.contributionsDisplay,
          ),
          SizedBox(width: 10.w),
          UserVffProfileMetricCard(
            label: AppStrings.userVffContributed,
            value: m.contributedDisplay,
          ),
          SizedBox(width: 10.w),
          UserVffProfileMetricCard(
            label: AppStrings.userVffProjectsLabel,
            value: m.projectsDisplay!,
          ),
        ],
      );
    }

    return Row(
      children: [
        UserVffProfileMetricCard(
          label: AppStrings.userVffContributed,
          value: m.contributedDisplay,
        ),
        SizedBox(width: 10.w),
        UserVffProfileMetricCard(
          label: AppStrings.userVffContributionsPlural,
          value: m.contributionsDisplay,
        ),
      ],
    );
  }
}
