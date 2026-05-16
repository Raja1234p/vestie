import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/common/app_avatar_circle.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../domain/entities/member_entity.dart';
import 'project_member_add_friend_button.dart';
import 'project_member_badges.dart';

/// Single member row — avatar, name, role badges, Add Friend (Figma).
class ProjectMemberRow extends StatelessWidget {
  final MemberEntity member;
  final ValueChanged<MemberEntity>? onTap;
  final VoidCallback? onAddFriend;
  final bool showVffBadge;

  const ProjectMemberRow({
    super.key,
    required this.member,
    this.onTap,
    this.onAddFriend,
    this.showVffBadge = false,
  });

  bool get _showLeaderBadge =>
      member.role == MemberRole.leader || member.role == MemberRole.coLeader;

  bool get _showAddFriend =>
      onAddFriend != null && member.role == MemberRole.member;

  @override
  Widget build(BuildContext context) {
    final avatarSize = AppDimens.projectMemberAvatarSize;

    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(member),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: AppDimens.projectMemberCardPadding,
        decoration: BoxDecoration(
          color: AppColors.projectMemberCardBg,
          borderRadius: BorderRadius.circular(AppRadius.r12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: AppAvatarCircle(
                initials: member.initials,
                size: avatarSize,
                backgroundColor: AppColors.projectMemberAvatarBg,
                textColor: AppColors.projectMemberAvatarInitials,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: AppDimens.projectMemberAvatarNameGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    member.name,
                    style: AppTextStyles.projectMemberName,
                  ),
                  if (_showLeaderBadge || showVffBadge) ...[
                    SizedBox(height: AppDimens.projectMemberNameBadgeGap),
                    Wrap(
                      spacing: AppDimens.p8,
                      runSpacing: AppDimens.v4,
                      children: [
                        if (_showLeaderBadge) const ProjectMemberLeaderBadge(),
                        if (showVffBadge) const ProjectMemberVffBadge(),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (_showAddFriend) ...[
              SizedBox(width: AppDimens.p8),
              ProjectMemberAddFriendButton(onPressed: onAddFriend!),
            ],
          ],
        ),
      ),
    );
  }
}
