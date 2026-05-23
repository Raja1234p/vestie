import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_success_vote/leader_success_vote_countdown.dart';

/// Full-width purple background — “Voting window closes in” + timer only (Figma).
class LeaderSuccessVoteCountdownSection extends StatelessWidget {
  final Duration initialRemaining;

  const LeaderSuccessVoteCountdownSection({
    super.key,
    required this.initialRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.purple100,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      child: LeaderSuccessVoteCountdown(initialRemaining: initialRemaining),
    );
  }
}
