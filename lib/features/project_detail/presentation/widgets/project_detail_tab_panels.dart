import 'package:flutter/material.dart';

import '../../domain/entities/borrow_request_entity.dart';
import '../../domain/entities/member_entity.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/borrow_requests_tab.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/borrow_request_card.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/borrow_request_decision_dialogs.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_manage_members_list.dart';
import 'members_list.dart';
import 'project_members_section.dart';

class UserBorrowRequestsPanel extends StatelessWidget {
  final List<BorrowRequestEntity> requests;
  final VoidCallback onViewAll;

  const UserBorrowRequestsPanel({
    super.key,
    required this.requests,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return BorrowRequestsTab(
      requests: requests,
      onViewAll: onViewAll,
    );
  }
}

class LeaderBorrowRequestsPanel extends StatelessWidget {
  final List<BorrowRequestEntity> requests;
  final VoidCallback onViewAll;

  const LeaderBorrowRequestsPanel({
    super.key,
    required this.requests,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return BorrowRequestsTab(
      requests: requests,
      onViewAll: onViewAll,
      actionMode: BorrowRequestActionMode.decision,
      onAccept: (r) => showApproveBorrowRequestFlow(context, r),
      onReject: (r) => showRejectBorrowRequestFlow(context, r),
    );
  }
}

class UserMembersPanel extends StatelessWidget {
  final List<MemberEntity> members;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onAddFriend;
  final bool useFigmaLayout;

  const UserMembersPanel({
    super.key,
    required this.members,
    this.onMemberTap,
    this.onAddFriend,
    this.useFigmaLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeMembers = members
        .where((m) => !m.status.toLowerCase().contains('pending'))
        .toList(growable: false);

    if (useFigmaLayout) {
      return ProjectMembersSection(
        members: activeMembers,
        onMemberTap: onMemberTap,
        onAddFriend: onAddFriend,
      );
    }

    return MembersList(
      members: activeMembers,
      onMemberTap: onMemberTap,
    );
  }
}

class LeaderMembersPanel extends StatelessWidget {
  final List<MemberEntity> members;
  final ValueChanged<MemberEntity>? onMemberTap;

  const LeaderMembersPanel({
    super.key,
    required this.members,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeMembers = members
        .where((m) => !m.status.toLowerCase().contains('pending'))
        .toList(growable: false);
    return LeaderManageMembersList(
      members: activeMembers,
      onMemberTap: onMemberTap,
    );
  }
}
