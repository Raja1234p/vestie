import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_avatar_circle.dart';
import '../../../../core/widgets/common/app_role_badge.dart';
import '../../domain/entities/member_entity.dart';

/// Scrollable member list displayed under the Members tab.
class MembersList extends StatelessWidget {
  final List<MemberEntity> members;

  const MembersList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: members
          .map((m) => _MemberRow(member: m))
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
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          // Avatar
          AppAvatarCircle(initials: member.initials),
          SizedBox(width: 12.w),

          // Name + badge
          Expanded(
            child: Row(
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey1100,
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
          Text(
            '+${_fmt(member.contributedAmount)}',
            style: GoogleFonts.lato(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
