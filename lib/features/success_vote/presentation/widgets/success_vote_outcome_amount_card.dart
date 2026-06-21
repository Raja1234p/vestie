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

  const SuccessVoteOutcomeAmountCard({
    super.key,
    required this.data,
    required this.copy,
  });

  static BoxDecoration _cardDecoration({
    required BorderRadius radius,
    required bool isApproved,
  }) =>
      BoxDecoration(
        color: isApproved ? AppColors.green100 : AppColors.red100,
        borderRadius: radius,
        border: Border.all(
          color: isApproved ? AppColors.green300 : AppColors.red300,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final caption = copy.amountCaptionFor(data.isApproved);
    final radius = BorderRadius.circular(12.r);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: _cardDecoration(radius: radius, isApproved: data.isApproved),
      child: Column(
        children: [
          AppText(
            caption,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          SizedBox(height: 6.h),
          AppText(
            '\$${data.formattedAmountUsd}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: data.isApproved ? AppColors.green900 : AppColors.red900,
            ),
          ),
        ],
      ),
    );
  }
}
