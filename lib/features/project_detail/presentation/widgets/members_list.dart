import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_avatar_circle.dart';
import '../../../../core/widgets/common/app_role_badge.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/member_entity.dart';

/// Scrollable member list displayed under the Members tab.
class MembersList extends StatelessWidget {
  final List<MemberEntity> members;

  const MembersList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: members
          .map((m) => Padding(
            padding:  EdgeInsets.only(bottom: 12.h),
            child: _MemberRow(member: m),
          ))
          .toList(),
    );
  }
}

// ── Member row ────────────────────────────────────────────────────────────────
class _MemberRow extends StatelessWidget {
  final MemberEntity member;
  const _MemberRow({required this.member});

  AppRoleType? get _roleType {
    switch (member.role) {
      case MemberRole.leader:   return AppRoleType.leader;
      case MemberRole.coLeader: return AppRoleType.coLeader;
      case MemberRole.member:   return null;
    }
  }

  String _fmt(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r)
      ),
      child: Row(
        children: [
          // Avatar
          AppAvatarCircle(initials: member.initials,size: 55.h),
          SizedBox(width: 12.w),

          // Name + badge
          Expanded(
            child: Row(
              children: [
                AppText(
                  member.name,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral1100,
                  ),
                ),
                if (_roleType != null) ...[
                  SizedBox(width: 8.w),
                  AppRoleBadge(role: _roleType!),
                ],
              ],
            ),
          ),

          // Amount
          AppText(
            '+${_fmt(member.contributedAmount)}',
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.badgeCompletedText,
            ),
          ),
        ],
      ),
    );
  }
}
