import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';
import 'package:vestie/features/project_detail/presentation/widgets/member_detail_actions_visibility.dart';
import '../widgets/member_detail_actions.dart';
import '../widgets/member_detail_result_dialogs.dart';
import '../widgets/penalty_action_content.dart';
import '../widgets/penalty_action_footer.dart';

class MemberPenaltyActionScreen extends StatefulWidget {
  final MemberEntity member;
  final String projectId;
  final ProjectDetailEntity? project;

  const MemberPenaltyActionScreen({
    super.key,
    required this.member,
    required this.projectId,
    this.project,
  });

  @override
  State<MemberPenaltyActionScreen> createState() =>
      _MemberPenaltyActionScreenState();
}

class _MemberPenaltyActionScreenState extends State<MemberPenaltyActionScreen> {
  ProjectDetailEntity? get _projectContext =>
      ProjectDetailReloadCoordinator.cachedProject(widget.projectId) ??
      widget.project;

  MemberEntity get _targetMember {
    final p = _projectContext;
    if (p == null) return widget.member;
    return widget.member.withProjectRoster(p);
  }

  String get _userId => _targetMember.apiUserId;

  bool get _showRemoveMember {
    final p = _projectContext;
    if (p == null) return false;
    return MemberDetailActionsVisibility.showRemoveMember(
      project: p,
      member: _targetMember,
    );
  }

  bool get _showMarkAsDefaulted {
    final p = _projectContext;
    if (p == null) return false;
    return MemberDetailActionsVisibility.showMarkAsDefaulted(
      project: p,
      member: _targetMember,
    );
  }

  Future<bool> _removeMember() async {
    final result = await ServiceLocator.instance.removeForNonRepaymentUseCase(
      projectId: widget.projectId,
      userId: _userId,
    );

    return result.fold(
      (failure) {
        showMemberDetailErrorDialog(context, failure: failure);
        return false;
      },
      (_) async {
        await ProjectDetailReloadCoordinator.reload(widget.projectId);
        return true;
      },
    );
  }

  Future<bool> _markDefaulted() async {
    final result = await ServiceLocator.instance.markDefaultedUseCase(
      projectId: widget.projectId,
      userId: _userId,
    );

    return result.fold(
      (failure) {
        showMemberDetailErrorDialog(context, failure: failure);
        return false;
      },
      (_) async {
        await ProjectDetailReloadCoordinator.reload(widget.projectId);
        return true;
      },
    );
  }

  Future<void> _promptRemoveMember() async {
    final removed = await showRemoveMemberFlow(
      context,
      memberName: _targetMember.name,
      onConfirm: _removeMember,
    );
    if (!mounted || !removed) return;
    context.pop(MemberPenaltyActionOutcome.memberRemoved);
  }

  Future<void> _promptMarkDefaulted() async {
    final marked = await showMarkDefaultedFlow(
      context,
      onConfirm: _markDefaulted,
    );
    if (!mounted || !marked) return;
    context.pop(MemberPenaltyActionOutcome.memberUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final showFooter = _showRemoveMember || _showMarkAsDefaulted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthFlowSubHeader(
              title: AppStrings.penaltyActionTitle,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppDimens.postAuthFlowScrollPadding,
                child: const PenaltyActionContent(),
              ),
            ),
            if (showFooter)
              PenaltyActionFooter(
                showRemoveMember: _showRemoveMember,
                showMarkAsDefaulted: _showMarkAsDefaulted,
                onRemoveMember: _promptRemoveMember,
                onMarkDefaulted: _promptMarkDefaulted,
              ),
          ],
        ),
      ),
    );
  }
}
