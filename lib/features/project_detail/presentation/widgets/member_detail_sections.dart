import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_network_avatar.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import '../../../../core/widgets/common/app_transaction_item.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/member_activity_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'member_detail_actions_visibility.dart';
import 'member_metric_card.dart';
import 'project_member_contribution_badge.dart';
import 'project_member_overdue_badge.dart';

class MemberIdentitySection extends StatelessWidget {
  final MemberEntity member;
  final String username;
  final String projectName;
  final ProjectDetailEntity? project;
  final bool isCoLeader;
  final bool isCoLeaderActionLoading;
  final VoidCallback? onAssignCoLeader;
  final VoidCallback? onRemoveCoLeader;

  const MemberIdentitySection({
    super.key,
    required this.member,
    required this.username,
    required this.projectName,
    this.project,
    required this.isCoLeader,
    this.isCoLeaderActionLoading = false,
    this.onAssignCoLeader,
    this.onRemoveCoLeader,
  });

  bool get _showCoLeaderRoleControls {
    final p = project;
    if (p == null) return false;
    return MemberDetailActionsVisibility.showCoLeaderControls(
      project: p,
      member: member,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppNetworkAvatar(
          imageUrl: member.photoUrl,
          initials: member.initials,
          size: 54.r,
          backgroundColor: AppColors.purple300,
          textColor: AppColors.grey1100,
          fontSize: 24.sp,
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
              if (member.showsContributionBadge) ...[
                SizedBox(height: 6.h),
                ProjectMemberContributionBadge(label: member.badge),
              ] else if (member.showsOverdueBadge) ...[
                SizedBox(height: 6.h),
                ProjectMemberOverdueBadge(
                  amount: member.overdueBadgeDisplayAmount,
                ),
              ],
            ],
          ),
        ),
        if (_showCoLeaderRoleControls) ...[
          SizedBox(width: 8.w),
          MemberLeaderRoleButton(
            isCoLeader: isCoLeader,
            isLoading: isCoLeaderActionLoading,
            onTap: isCoLeaderActionLoading
                ? null
                : () => isCoLeader
                      ? onRemoveCoLeader?.call()
                      : onAssignCoLeader?.call(),
          ),
        ],
      ],
    );
  }
}

class MemberLeaderRoleButton extends StatelessWidget {
  final bool isCoLeader;
  final bool isLoading;
  final VoidCallback? onTap;

  const MemberLeaderRoleButton({
    super.key,
    required this.isCoLeader,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isCoLeader) {
      return AppButton(
        text: AppStrings.btnRemoveCoLeader,
        onPressed: onTap,
        isLoading: isLoading,
        width: 145.w,
        height: 41.h,
        labelFontSize: 14.sp,
        hasShadow: false,
        color: AppColors.red700,
        borderColor: AppColors.red900,
        useGradient: false,
      );
    }

    return AppButton(
      text: AppStrings.btnMakeCoLeader,
      onPressed: onTap,
      isLoading: isLoading,
      width: 142.w,
      height: 41.h,
      labelFontSize: 14.sp,
      hasShadow: false,
      color: AppColors.purple800,
      borderColor: AppColors.purple900,
      useGradient: false,
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
  final List<MemberActivityTransactionEntity> transactions;

  const MemberTransactionsSection({super.key, required this.transactions});

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
        if (transactions.isEmpty)
          AppText(
            AppStrings.memberActivityEmptyTransactions,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 15.sp,
              color: AppColors.grey800,
            ),
          )
        else
          ...transactions.map(_buildRow),
      ],
    );
  }

  Widget _buildRow(MemberActivityTransactionEntity tx) {
    final isBorrow = tx.kind == MemberActivityTransactionKind.borrow;
    final type = isBorrow
        ? AppTransactionType.borrow
        : AppTransactionType.contribution;
    final amount = MemberActivityDisplay.formatLedgerAmount(tx.amount);

    return AppTransactionItem(
      type: type,
      title: tx.title,
      date: tx.displayDate,
      amount: amount,
      isNegative: isBorrow,
    );
  }
}

/// Display helpers for member activity metrics and ledger rows.
abstract final class MemberActivityDisplay {
  static String formatUsername(MemberEntity member) {
    final raw = member.username.trim();
    if (raw.isEmpty) {
      final slug = member.name.toLowerCase().replaceAll(' ', '-');
      return '@$slug';
    }
    return raw.startsWith('@') ? raw : '@$raw';
  }

  static String formatCurrencyMetric(double value) =>
      '\$${formatLedgerAmount(value)}';

  static String formatLedgerAmount(double value) {
    final abs = value.abs();
    if (abs == abs.roundToDouble()) {
      return abs
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    }
    return abs
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }
}

class MemberOverdueBanner extends StatelessWidget {
  final MemberEntity member;
  final String? projectId;
  final ProjectDetailEntity? project;
  final int overdueBorrowCount;
  final VoidCallback? onTakeAction;

  const MemberOverdueBanner({
    super.key,
    required this.member,
    this.projectId,
    this.project,
    this.overdueBorrowCount = 0,
    this.onTakeAction,
  });

  bool get _showTakeAction {
    final p = project;
    if (p == null) return false;
    return MemberDetailActionsVisibility.showOverdueTakeAction(
      project: p,
      member: member,
    );
  }

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
          AppSvgIcon(
            assetPath: AppAssets.iconAlertTriangle,
            color: AppColors.red900,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: AppText(
              AppStrings.memberOverdueBorrowNotice(overdueBorrowCount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15.sp,
                color: AppColors.red900,
              ),
            ),
          ),
          if (_showTakeAction) ...[
            SizedBox(width: 8.w),
            AppButton(
              text: AppStrings.btnTakeAction,
              onPressed: onTakeAction,
              width: 120.w,
              height: 40.h,
              hasShadow: false,
              useGradient: false,
              color: AppColors.red700,
            ),
          ],
        ],
      ),
    );
  }
}
