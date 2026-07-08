import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';

/// Mint / rose amount card — same layout for every viewer role.
class SuccessVoteOutcomeAmountCard extends StatelessWidget {
  final SuccessVoteOutcomeUiData data;
  final SuccessVoteOutcomeCopy copy;
  final String? captionOverride;
  final bool rejectedCaptionAccentRed;

  const SuccessVoteOutcomeAmountCard({
    super.key,
    required this.data,
    required this.copy,
    this.captionOverride,
    this.rejectedCaptionAccentRed = false,
  });

  static BoxDecoration _cardDecoration({
    required BorderRadius radius,
    required bool isApproved,
  }) =>
      BoxDecoration(
        color: isApproved
            ? AppColors.successVoteOutcomeApprovedAmountCardBg
            : AppColors.successVoteOutcomeRejectedAmountCardBg,
        borderRadius: radius,
        border: Border.all(
          color: isApproved
              ? AppColors.successVoteOutcomeApprovedAmountCardBorder
              : AppColors.successVoteOutcomeRejectedAmountCardBorder,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final caption = captionOverride ?? copy.amountCaptionFor(data.isApproved);
    final radius = BorderRadius.circular(12.r);
    final isApproved = data.isApproved;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: _cardDecoration(radius: radius, isApproved: isApproved),
      child: Column(
        children: [
          AppText(
            caption,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isApproved
                  ? AppColors.neutral700
                  : rejectedCaptionAccentRed
                  ? AppColors.red800
                  : AppColors.neutral700,
            ),
          ),
          SizedBox(height: 6.h),
          AppText(
            '\$${data.formattedAmountUsd}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: isApproved ? AppColors.green900 : AppColors.red900,
            ),
          ),
        ],
      ),
    );
  }
}
