import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import '../../domain/entities/borrow_request_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/borrow_requests_tab.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/borrow_request_card.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/borrow_request_decision_dialogs.dart';
import 'members_tab.dart';

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

  Future<bool> _approve(BuildContext context, BorrowRequestEntity request) async {
    final result = await ServiceLocator.instance.approveBorrowRequestUseCase(
      projectId: project.id,
      borrowRequestId: request.id,
    );
    return result.fold((failure) {
      AppToast.showError(context, failure.message);
      return false;
    }, (_) async {
      await context.read<ProjectDetailBloc>().reloadDetailAndWait(project.id);
      return true;
    });
  }

  Future<bool> _reject(BuildContext context, BorrowRequestEntity request) async {
    final result = await ServiceLocator.instance.rejectBorrowRequestUseCase(
      projectId: project.id,
      borrowRequestId: request.id,
    );
    return result.fold((failure) {
      AppToast.showError(context, failure.message);
      return false;
    }, (_) async {
      await context.read<ProjectDetailBloc>().reloadDetailAndWait(project.id);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BorrowRequestsTab(
      project: project,
      requests: requests,
      onViewAll: onViewAll,
      actionMode: BorrowRequestActionMode.decision,
      onMemberTap: onMemberTap,
      onAccept: (r) => showApproveBorrowRequestFlow(
        context,
        r,
        () => _approve(context, r),
      ),
      onReject: (r) => showRejectBorrowRequestFlow(
        context,
        r,
        () => _reject(context, r),
      ),
    );
  }
}

class UserMembersPanel extends StatelessWidget {
  final ProjectDetailEntity project;
  final List<MemberEntity> members;
  final VoidCallback onViewAll;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onSendVffRequest;
  final String? sendingVffUserId;

  const UserMembersPanel({
    super.key,
    required this.project,
    required this.members,
    required this.onViewAll,
    this.onMemberTap,
    this.onSendVffRequest,
    this.sendingVffUserId,
  });

  @override
  Widget build(BuildContext context) {
    return MembersTab(
      project: project,
      members: members,
      onViewAll: onViewAll,
      onMemberTap: onMemberTap,
      onSendVffRequest: onSendVffRequest,
      sendingVffUserId: sendingVffUserId,
    );
  }
}

class LeaderMembersPanel extends StatelessWidget {
  final ProjectDetailEntity project;
  final List<MemberEntity> members;
  final VoidCallback onViewAll;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onSendVffRequest;
  final String? sendingVffUserId;

  const LeaderMembersPanel({
    super.key,
    required this.project,
    required this.members,
    required this.onViewAll,
    this.onMemberTap,
    this.onSendVffRequest,
    this.sendingVffUserId,
  });

  @override
  Widget build(BuildContext context) {
    return MembersTab(
      project: project,
      members: members,
      onViewAll: onViewAll,
      onMemberTap: onMemberTap,
      onSendVffRequest: onSendVffRequest,
      sendingVffUserId: sendingVffUserId,
    );
  }
}
