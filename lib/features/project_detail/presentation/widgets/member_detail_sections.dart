import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_transaction_item.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/member_entity.dart';
import 'member_detail_actions.dart';
import 'member_metric_card.dart';

class MemberIdentitySection extends StatelessWidget {
  final MemberEntity member;
  final String username;
  final String projectName;
  final bool isLeaderView;
  final bool isCoLeader;

  const MemberIdentitySection({
    super.key,
    required this.member,
    required this.username,
    required this.projectName,
    required this.isLeaderView,
    required this.isCoLeader,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 27.r,
          backgroundColor: AppColors.purple300,
          child: AppText(
            member.initials,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey1100,
                ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                member.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey1100,
                    ),
              ),
              SizedBox(height: 2.h),
              AppText(
                username,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey800,
                    ),
              ),
            ],
          ),
        ),
        if (isLeaderView) ...[
          SizedBox(width: 8.w),
          MemberLeaderRoleButton(
            isCoLeader: isCoLeader,
            onTap: () => isCoLeader
                ? showRemoveCoLeaderFlow(
                    context,
                    memberName: member.name,
                    projectName: projectName,
                  )
                : showMakeCoLeaderFlow(
                    context,
                    memberName: member.name,
                    projectName: projectName,
                  ),
          ),
        ],
      ],
    );
  }
}

class MemberMetricsSection extends StatelessWidget {
  final String contributed;
  final String contributions;
  final String borrowed;

  const MemberMetricsSection({
    super.key,
    required this.contributed,
    required this.contributions,
    required this.borrowed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MemberMetricCard(
            label: AppStrings.contributedLabel,
            value: contributed,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: MemberMetricCard(
            label: AppStrings.contributionsLabel,
            value: contributions,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: MemberMetricCard(
            label: AppStrings.borrowedLabelShort,
            value: borrowed,
          ),
        ),
      ],
    );
  }
}

class MemberTransactionsSection extends StatelessWidget {
  final String projectName;
  final String borrowedAmount;

  const MemberTransactionsSection({
    super.key,
    required this.projectName,
    required this.borrowedAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          AppStrings.transactionHistoryTitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.grey1100,
              ),
        ),
        SizedBox(height: 14.h),
        AppTransactionItem(
          type: AppTransactionType.contribution,
          title: '${AppStrings.txContributionPrefix}$projectName',
          date: AppStrings.memberTxDateMar11,
          amount: '400',
          isNegative: false,
        ),
        AppTransactionItem(
          type: AppTransactionType.contribution,
          title: '${AppStrings.txContributionPrefix}$projectName',
          date: AppStrings.memberTxDateMar11,
          amount: '600',
          isNegative: false,
        ),
        AppTransactionItem(
          type: AppTransactionType.borrow,
          title: '${AppStrings.txBorrowPrefix}$projectName',
          date: AppStrings.memberTxDateMar12,
          amount: borrowedAmount,
          isNegative: true,
        ),
      ],
    );
  }
}

class MemberOverdueBanner extends StatelessWidget {
  final MemberEntity member;

  const MemberOverdueBanner({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.red100,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.red900, size: 20.w),
          SizedBox(width: 8.w),
          Expanded(
            child: AppText(
              AppStrings.overdueBorrowNotice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.red900,
                  ),
            ),
          ),
          SizedBox(width: 8.w),
          AppButton(
            text: AppStrings.btnTakeAction,
            onPressed: () => context.push(
              AppRoutes.memberPenaltyAction,
              extra: member,
            ),
            width: 120.w,
            height: 40.h,
            hasShadow: false,
            useGradient: false,
            color: AppColors.red700,
          ),
        ],
      ),
    );
  }
}

class MemberLeaderRoleButton extends StatelessWidget {
  final bool isCoLeader;
  final VoidCallback onTap;

  const MemberLeaderRoleButton({
    super.key,
    required this.isCoLeader,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: isCoLeader ? AppStrings.btnRemoveCoLeader : AppStrings.btnMakeCoLeader,
      onPressed: onTap,
      width: 145.w,
      height: 44.h,
      hasShadow: false,
      color: isCoLeader ? AppColors.red800 : null,
      useGradient: !isCoLeader,
    );
  }
}

