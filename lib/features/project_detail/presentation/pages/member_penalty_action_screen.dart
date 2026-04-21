import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/member_entity.dart';
import '../widgets/member_detail_actions.dart';

class MemberPenaltyActionScreen extends StatelessWidget {
  final MemberEntity member;

  const MemberPenaltyActionScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostAuthHeader(
                title: AppStrings.penaltyActionTitle,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.grey1100,
                    size: 22.w,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              const _PenaltyOverviewCard(),
              SizedBox(height: 22.h),
              LeaderActionOutlineButton(
                label: AppStrings.btnRemoveMember,
                onTap: () => showRemoveMemberConfirm(
                  context,
                  memberName: member.name,
                ),
              ),
              SizedBox(height: 14.h),
              LeaderActionOutlineButton(
                label: AppStrings.markAsDefaulted,
                onTap: () => showMarkDefaultedConfirm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PenaltyOverviewCard extends StatelessWidget {
  const _PenaltyOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grey400),
      ),
      child: Column(
        children: [
          _row(AppStrings.penaltyBorrowedLabel, AppStrings.penaltyBorrowedAmount),
          SizedBox(height: 10.h),
          _row(AppStrings.penaltyDueLabel, AppStrings.penaltyDueDateValue),
          SizedBox(height: 10.h),
          _row(AppStrings.penaltyOverdueLabel, AppStrings.penaltyOverdueValue),
          SizedBox(height: 10.h),
          _row(AppStrings.penaltyPenaltyLabel, AppStrings.penaltyChargeValue),
          SizedBox(height: 12.h),
          Divider(height: 1.h, color: AppColors.grey400),
          SizedBox(height: 12.h),
          _row(
            AppStrings.penaltyTotalOwedLabel,
            AppStrings.penaltyTotalOwedValue,
            strong: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool strong = false}) {
    return Builder(
      builder: (context) => Row(
        children: [
          AppText(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16.sp,
                  color: strong ? AppColors.grey1100 : AppColors.grey700,
                ),
          ),
          const Spacer(),
          AppText(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
                  color: AppColors.grey1100,
                ),
          ),
        ],
      ),
    );
  }
}
