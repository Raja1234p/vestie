import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/member_entity_extensions.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'project_member_row.dart';
import 'project_members_empty_state.dart';

/// “Members” block on project detail (Figma — empty + list with Add Friend).
class ProjectMembersSection extends StatelessWidget {
  final String title;
  final List<MemberEntity> members;
  final ProjectDetailEntity? project;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onSendVffRequest;
  final String? sendingVffUserId;
  final bool Function(MemberEntity member)? showVffBadgeFor;
  final bool showTitle;

  const ProjectMembersSection({
    super.key,
    this.title = AppStrings.tabMembers,
    required this.members,
    this.project,
    this.onMemberTap,
    this.onSendVffRequest,
    this.sendingVffUserId,
    this.showVffBadgeFor,
    this.showTitle = true,
  });

  List<MemberEntity> get _activeMembers => members
      .where((m) => !m.status.toLowerCase().contains('pending'))
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final active = _activeMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          AppText(
            title,
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
            ),
          ),
          SizedBox(height: 14.h),
        ],
        if (active.isEmpty)
          const ProjectMembersEmptyState()
        else
          ...active.map(
            (member) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: ProjectMemberRow(
                member: member,
                project: project,
                onTap: onMemberTap,
                onAddFriend: onSendVffRequest == null
                    ? null
                    : () => onSendVffRequest!(member),
                isSendVffLoading:
                    sendingVffUserId != null &&
                    sendingVffUserId == member.apiUserId,
                vffRequestSent: member.hasPendingVffOutgoing,
                showVffBadge:
                    showVffBadgeFor?.call(member) ?? member.showsVffBadgeOnMemberRow,
              ),
            ),
          ),
      ],
    );
  }
}
