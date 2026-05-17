import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Borrowed amount + breakdown card (Figma Penalty Action).
class PenaltyActionContent extends StatelessWidget {
  const PenaltyActionContent({super.key});

  /// Figma — Due / Overdue / Penalty row copy (#737373).
  static const Color _breakdownRowColor = AppColors.neutral700;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.penaltyBorrowedLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
            ),
          ),
          SizedBox(height: 6.h),
          AppText(
            AppStrings.penaltyBorrowedAmount,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral1200,
              height: 1.15,
            ),
          ),
          SizedBox(height: 24.h),
          AppText(
            AppStrings.labelBreakdown,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.grey1100,
            ),
          ),
          SizedBox(height: 12.h),
          const _PenaltyBreakdownCard(),
        ],
      ),
    );
  }
}

class _PenaltyBreakdownCard extends StatelessWidget {
  const _PenaltyBreakdownCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey400),
      ),
      child: Column(
        children: [
          const _BreakdownRow(
            label: AppStrings.penaltyDueLabel,
            value: AppStrings.penaltyDueAmount,
          ),
          SizedBox(height: 14.h),
          const _BreakdownRow(
            label: AppStrings.penaltyOverdueLabel,
            value: AppStrings.penaltyOverdueDateValue,
          ),
          SizedBox(height: 14.h),
          const _BreakdownRow(
            label: AppStrings.penaltyPenaltyLabel,
            value: AppStrings.penaltyChargeValue,
          ),
          SizedBox(height: 16.h),
          Divider(height: 1.h, color: AppColors.grey400),
          SizedBox(height: 16.h),
          const _BreakdownRow(
            label: AppStrings.penaltyTotalOwedLabel,
            value: AppStrings.penaltyTotalOwedValue,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = isTotal
        ? AppTextStyles.bodyLarge.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.grey1100,
          )
        : AppTextStyles.bodyMedium.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: PenaltyActionContent._breakdownRowColor,
          );

    final valueStyle = isTotal
        ? AppTextStyles.bodyLarge.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.red800,
          )
        : AppTextStyles.bodyLarge.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: PenaltyActionContent._breakdownRowColor,
          );

    return Row(
      children: [
        AppText(label, style: labelStyle),
        const Spacer(),
        AppText(value, style: valueStyle),
      ],
    );
  }
}
