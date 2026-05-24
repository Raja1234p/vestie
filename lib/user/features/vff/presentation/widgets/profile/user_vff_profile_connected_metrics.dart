import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import '../../models/user_vff_profile_ui_model.dart';
import 'user_vff_profile_metric_card.dart';

/// Contributions + Projects stat cards (connected VFF profile — Figma).
final class UserVffProfileConnectedMetrics extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileConnectedMetrics({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final m = profile.metrics;
    return Row(
      children: [
        UserVffProfileMetricCard(
          label: AppStrings.userVffContributionsPlural,
          value: m.contributionsDisplay,
        ),
        SizedBox(width: 10.w),
        UserVffProfileMetricCard(
          label: AppStrings.userVffProjectsLabel,
          value: m.projectsDisplay ?? '0',
        ),
      ],
    );
  }
}
