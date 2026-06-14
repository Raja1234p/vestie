import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_network_avatar.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_member_overdue_badge.dart';

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
              child: _LeaderMemberRow(member: member, onTap: onMemberTap),
            ),
          )
          .toList(),
    );
  }
}

class _LeaderMemberRow extends StatelessWidget {
  final MemberEntity member;
  final ValueChanged<MemberEntity>? onTap;

  const _LeaderMemberRow({required this.member, this.onTap});

  bool get _showOverdue => member.showsOverdueBadge;

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
            AppNetworkAvatar(
              imageUrl: member.photoUrl,
              initials: member.initials,
              size: 48.h,
              backgroundColor: AppColors.purple300,
              textColor: AppColors.grey1100,
            ),
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
            if (_showOverdue)
              ProjectMemberOverdueBadge(
                amount: member.overdueBadgeDisplayAmount,
              ),
          ],
        ),
      ),
    );
  }
}
