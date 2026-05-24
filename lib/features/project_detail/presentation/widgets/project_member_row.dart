import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/common/app_network_avatar.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'project_member_add_friend_button.dart';
import 'project_member_add_friend_visibility.dart';
import 'project_member_co_leader_badge.dart';
import 'project_member_leader_badge.dart';
import 'project_member_vff_badge.dart';

/// Single member row — avatar, name, role badges, Add Friend (Figma).
class ProjectMemberRow extends StatelessWidget {
  final MemberEntity member;
  final ProjectDetailEntity? project;
  final ValueChanged<MemberEntity>? onTap;
  final VoidCallback? onAddFriend;
  final bool isSendVffLoading;
  final bool vffRequestSent;
  final bool showVffBadge;

  const ProjectMemberRow({
    super.key,
    required this.member,
    this.project,
    this.onTap,
    this.onAddFriend,
    this.isSendVffLoading = false,
    this.vffRequestSent = false,
    this.showVffBadge = false,
  });

  bool get _showRoleBadge =>
      member.role == MemberRole.leader || member.role == MemberRole.coLeader;

  bool get _canShowVffCta {
    if (onAddFriend == null) return false;
    if (project != null) {
      return ProjectMemberAddFriendVisibility.shouldShow(
            project: project!,
            member: member,
          ) ||
          vffRequestSent;
    }
    return member.role == MemberRole.member || vffRequestSent;
  }

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
              child: AppNetworkAvatar(
                imageUrl: member.photoUrl,
                initials: member.initials,
                size: avatarSize,
                backgroundColor: AppColors.projectMemberAvatarBg,
                textColor: AppColors.projectMemberAvatarInitials,
                fontSize: 16.sp,
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
                  if (_showRoleBadge || showVffBadge) ...[
                    SizedBox(height: AppDimens.projectMemberNameBadgeGap),
                    Wrap(
                      spacing: AppDimens.p8,
                      runSpacing: AppDimens.v4,
                      children: [
                        if (member.role == MemberRole.leader)
                          const ProjectMemberLeaderBadge()
                        else if (member.role == MemberRole.coLeader &&
                            (project == null || project!.supportsCoLeader))
                          const ProjectMemberCoLeaderBadge(),
                        if (showVffBadge) const ProjectMemberVffBadge(),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (_canShowVffCta) ...[
              SizedBox(width: AppDimens.p8),
              ProjectMemberAddFriendButton(
                onPressed: vffRequestSent ? null : onAddFriend,
                isLoading: isSendVffLoading,
                requestSent: vffRequestSent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
