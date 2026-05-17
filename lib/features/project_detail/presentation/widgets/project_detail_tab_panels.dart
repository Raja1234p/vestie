import 'package:flutter/material.dart';

import '../../domain/entities/borrow_request_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/borrow_requests_tab.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/borrow_request_card.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/borrow_request_decision_dialogs.dart';
import 'project_members_section.dart';

class UserBorrowRequestsPanel extends StatelessWidget {
  final ProjectDetailEntity project;
  final List<BorrowRequestEntity> requests;
  final VoidCallback onViewAll;
  final ValueChanged<MemberEntity>? onMemberTap;

  const UserBorrowRequestsPanel({
    super.key,
    required this.project,
    required this.requests,
    required this.onViewAll,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return BorrowRequestsTab(
      project: project,
      requests: requests,
      onViewAll: onViewAll,
      onMemberTap: onMemberTap,
    );
  }
}

class LeaderBorrowRequestsPanel extends StatelessWidget {
  final ProjectDetailEntity project;
  final List<BorrowRequestEntity> requests;
  final VoidCallback onViewAll;
  final ValueChanged<MemberEntity>? onMemberTap;

  const LeaderBorrowRequestsPanel({
    super.key,
    required this.project,
    required this.requests,
    required this.onViewAll,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return BorrowRequestsTab(
      project: project,
      requests: requests,
      onViewAll: onViewAll,
      actionMode: BorrowRequestActionMode.decision,
      onMemberTap: onMemberTap,
      onAccept: (r) => showApproveBorrowRequestFlow(context, r),
      onReject: (r) => showRejectBorrowRequestFlow(context, r),
    );
  }
}

class UserMembersPanel extends StatelessWidget {
  final ProjectDetailEntity project;
  final List<MemberEntity> members;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onAddFriend;

  const UserMembersPanel({
    super.key,
    required this.project,
    required this.members,
    this.onMemberTap,
    this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    final activeMembers = members
        .where((m) => !m.status.toLowerCase().contains('pending'))
        .toList(growable: false);

    return ProjectMembersSection(
      showTitle: false,
      project: project,
      members: activeMembers,
      onMemberTap: onMemberTap,
      onAddFriend: onAddFriend,
    );
  }
}

class LeaderMembersPanel extends StatelessWidget {
  final ProjectDetailEntity project;
  final List<MemberEntity> members;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onAddFriend;

  const LeaderMembersPanel({
    super.key,
    required this.project,
    required this.members,
    this.onMemberTap,
    this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    final activeMembers = members
        .where((m) => !m.status.toLowerCase().contains('pending'))
        .toList(growable: false);
    return ProjectMembersSection(
      showTitle: false,
      project: project,
      members: activeMembers,
      onMemberTap: onMemberTap,
      onAddFriend: onAddFriend,
    );
  }
}
