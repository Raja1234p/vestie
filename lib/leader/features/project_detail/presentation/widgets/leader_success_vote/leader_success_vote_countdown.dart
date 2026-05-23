import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// “Voting window closes in” + single white timer card (inside purple top section).
class LeaderSuccessVoteCountdown extends StatefulWidget {
  final Duration initialRemaining;

  const LeaderSuccessVoteCountdown({super.key, required this.initialRemaining});

  @override
  State<LeaderSuccessVoteCountdown> createState() =>
      _LeaderSuccessVoteCountdownState();
}

class _LeaderSuccessVoteCountdownState extends State<LeaderSuccessVoteCountdown> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialRemaining;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.grey1100,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          AppStrings.leaderSuccessVoteWindowClosesIn,
          style: titleStyle,
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.neutral400),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _TimerSegment(
                    value: hours,
                    unit: AppStrings.leaderSuccessVoteTimerHr,
                  ),
                ),
                VerticalDivider(
                  width: 1.w,
                  thickness: 1,
                  color: AppColors.neutral400,
                ),
                Expanded(
                  child: _TimerSegment(
                    value: minutes,
                    unit: AppStrings.leaderSuccessVoteTimerMin,
                  ),
                ),
                VerticalDivider(
                  width: 1.w,
                  thickness: 1,
                  color: AppColors.neutral400,
                ),
                Expanded(
                  child: _TimerSegment(
                    value: seconds,
                    unit: AppStrings.leaderSuccessVoteTimerSec,
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

class _TimerSegment extends StatelessWidget {
  final int value;
  final String unit;

  const _TimerSegment({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            value.toString().padLeft(2, '0'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey1100,
                  height: 1.1,
                ),
          ),
          SizedBox(height: 4.h),
          AppText(
            unit,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey1100,
                ),
          ),
        ],
      ),
    );
  }
}
