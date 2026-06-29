import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/domain/entities/member_activity_penalty_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/member_detail_sections.dart';

/// Borrowed amount + breakdown card (Figma Penalty Action).
class PenaltyActionContent extends StatelessWidget {
  final MemberActivityPenaltyEntity penalty;

  const PenaltyActionContent({super.key, required this.penalty});

  /// Figma — Due / Overdue / Penalty row copy (#737373).
  static const Color _breakdownRowColor = AppColors.neutral700;

  String get _borrowedAmountLabel =>
      MemberActivityDisplay.formatCurrencyMetric(penalty.borrowedAmount);

  String get _dueAmountLabel =>
      MemberActivityDisplay.formatCurrencyMetric(penalty.breakdown.dueAmount);

  String get _overdueDateLabel =>
      _formatOverdueDate(penalty.breakdown.overdueDateUtc);

  String get _penaltyAmountLabel => MemberActivityDisplay.formatCurrencyMetric(
    penalty.breakdown.penaltyAmount,
  );

  String get _totalOwedLabel =>
      MemberActivityDisplay.formatCurrencyMetric(penalty.breakdown.totalOwed);

  static String _formatOverdueDate(DateTime? utc) {
    if (utc == null) return AppStrings.emptyData;
    return DateFormat('MMM d, yyyy').format(utc.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          _borrowedAmountLabel,
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
        _PenaltyBreakdownCard(
          dueAmount: _dueAmountLabel,
          overdueDate: _overdueDateLabel,
          penaltyAmount: _penaltyAmountLabel,
          totalOwed: _totalOwedLabel,
        ),
      ],
    );
  }
}

class _PenaltyBreakdownCard extends StatelessWidget {
  final String dueAmount;
  final String overdueDate;
  final String penaltyAmount;
  final String totalOwed;

  const _PenaltyBreakdownCard({
    required this.dueAmount,
    required this.overdueDate,
    required this.penaltyAmount,
    required this.totalOwed,
  });

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
          _BreakdownRow(
            label: AppStrings.penaltyDueLabel,
            value: dueAmount,
          ),
          SizedBox(height: 14.h),
          _BreakdownRow(
            label: AppStrings.penaltyOverdueLabel,
            value: overdueDate,
          ),
          SizedBox(height: 14.h),
          _BreakdownRow(
            label: AppStrings.penaltyPenaltyLabel,
            value: penaltyAmount,
          ),
          SizedBox(height: 16.h),
          Divider(height: 1.h, color: AppColors.grey400),
          SizedBox(height: 16.h),
          _BreakdownRow(
            label: AppStrings.penaltyTotalOwedLabel,
            value: totalOwed,
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
