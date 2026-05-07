import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/member_entity.dart';
import '../widgets/member_detail_actions.dart';

class MemberPenaltyActionScreen extends StatelessWidget {
  final MemberEntity member;
  final String projectId;

  const MemberPenaltyActionScreen({
    super.key,
    required this.member,
    required this.projectId,
  });

  Future<void> _removeMember(BuildContext context) async {
    final result = await ServiceLocator.instance.removeForNonRepaymentUseCase(
      projectId: projectId,
      userId: member.id,
    );
    if (!context.mounted) return;
    result.fold(
      (failure) => AppSnackBar.showError(context, failure.message),
      (_) => AppSnackBar.showSuccess(context, 'Member removed successfully'),
    );
  }

  Future<void> _markDefaulted(BuildContext context) async {
    final result = await ServiceLocator.instance.markDefaultedUseCase(
      projectId: projectId,
      userId: member.id,
    );
    if (!context.mounted) return;
    result.fold(
      (failure) => AppSnackBar.showError(context, failure.message),
      (_) => AppSnackBar.showSuccess(context, 'Member marked as defaulted'),
    );
  }

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
                leading: AppBackButton(
                  onPressed: () => context.pop(),
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
                  onConfirmed: () => _removeMember(context),
                ),
              ),
              SizedBox(height: 14.h),
              LeaderActionOutlineButton(
                label: AppStrings.markAsDefaulted,
                onTap: () => showMarkDefaultedConfirm(
                  context,
                  onConfirmed: () => _markDefaulted(context),
                ),
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
