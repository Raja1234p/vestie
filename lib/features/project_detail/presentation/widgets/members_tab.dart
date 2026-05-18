import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'project_detail_view_all_link.dart';
import 'project_member_row.dart';
import 'project_members_empty_state.dart';

/// Inline members tab — preview rows + View All → full list (Figma).
class MembersTab extends StatelessWidget {
  final ProjectDetailEntity project;
  final List<MemberEntity> members;
  final VoidCallback onViewAll;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onAddFriend;

  /// When false, parent supplies header link (investment Members row).
  final bool showViewAllLink;

  const MembersTab({
    super.key,
    required this.project,
    required this.members,
    required this.onViewAll,
    this.onMemberTap,
    this.onAddFriend,
    this.showViewAllLink = true,
  });

  List<MemberEntity> get _activeMembers => members
      .where((m) => !m.status.toLowerCase().contains('pending'))
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final active = _activeMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showViewAllLink)
          ProjectDetailViewAllLink(
            label: AppStrings.viewAllMembers,
            onTap: onViewAll,
          ),
        if (active.isEmpty)
          const ProjectMembersEmptyState(compactTop: true)
        else
          ...active.take(2).map(
                (member) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ProjectMemberRow(
                    member: member,
                    project: project,
                    onTap: onMemberTap,
                    onAddFriend: onAddFriend == null
                        ? null
                        : () => onAddFriend!(member),
                  ),
                ),
              ),
      ],
    );
  }
}
