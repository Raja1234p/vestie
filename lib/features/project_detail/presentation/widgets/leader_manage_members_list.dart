import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_avatar_circle.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/member_entity.dart';

class LeaderManageMembersList extends StatelessWidget {
  final List<MemberEntity> members;
  final ValueChanged<MemberEntity>? onMemberTap;

  const LeaderManageMembersList({
    super.key,
    required this.members,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: members
          .map(
            (member) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _LeaderMemberRow(
                member: member,
                onTap: onMemberTap,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _LeaderMemberRow extends StatelessWidget {
  final MemberEntity member;
  final ValueChanged<MemberEntity>? onTap;

  const _LeaderMemberRow({
    required this.member,
    this.onTap,
  });

  bool get _showOverdue =>
      member.overdueAmount != null && member.overdueAmount! > 0;

  String _fmt(double value) => value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(member),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Row(
          children: [
            AppAvatarCircle(initials: member.initials, size: 48.h),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    member.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey1000,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  AppText(
                    '${AppStrings.labelContributedWithColon}\$${_fmt(member.contributedAmount.abs())}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.grey1000,
                        ),
                  ),
                ],
              ),
            ),
            if (_showOverdue) _LeaderOverdueBadge(amount: member.overdueAmount!),
          ],
        ),
      ),
    );
  }
}

class _LeaderOverdueBadge extends StatelessWidget {
  final double amount;

  const _LeaderOverdueBadge({required this.amount});

  String _fmt(double value) => value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.red100,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.red300),
      ),
      child: AppText(
        '${AppStrings.overdueLabel.toUpperCase()} - \$${_fmt(amount)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.red800,
            ),
      ),
    );
  }
}
