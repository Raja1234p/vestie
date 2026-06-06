import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
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
  bool _isRemoving = false;
  bool _isMarkingDefaulted = false;

  String get _userId => widget.member.apiUserId;

  bool get _showRemoveMember {
    final p = widget.project;
    if (p == null) return false;
    return MemberDetailActionsVisibility.showRemoveMember(
      project: p,
      member: widget.member,
    );
  }

  bool get _showMarkAsDefaulted {
    final p = widget.project;
    if (p == null) return false;
    return MemberDetailActionsVisibility.showMarkAsDefaulted(
      project: p,
      member: widget.member,
    );
  }

  Future<void> _removeMember() async {
    if (_isRemoving || _isMarkingDefaulted) return;
    setState(() => _isRemoving = true);

    final result = await ServiceLocator.instance.removeForNonRepaymentUseCase(
      projectId: widget.projectId,
      userId: _userId,
    );

    await result.fold(
      (failure) async {
        if (!mounted) return;
        setState(() => _isRemoving = false);
        showMemberDetailErrorDialog(context, failure: failure);
      },
      (_) async {
        await ProjectDetailReloadCoordinator.reload(widget.projectId);
        if (!mounted) return;
        setState(() => _isRemoving = false);
        showMemberRemovedSuccess(
          context,
          onOk: () {
            Navigator.of(context).pop();
            context.pop(MemberPenaltyActionOutcome.memberRemoved);
          },
        );
      },
    );
  }

  Future<void> _markDefaulted() async {
    if (_isRemoving || _isMarkingDefaulted) return;
    setState(() => _isMarkingDefaulted = true);

    final result = await ServiceLocator.instance.markDefaultedUseCase(
      projectId: widget.projectId,
      userId: _userId,
    );

    await result.fold(
      (failure) async {
        if (!mounted) return;
        setState(() => _isMarkingDefaulted = false);
        showMemberDetailErrorDialog(context, failure: failure);
      },
      (_) async {
        await ProjectDetailReloadCoordinator.reload(widget.projectId);
        if (!mounted) return;
        setState(() => _isMarkingDefaulted = false);
        showMemberMarkedDefaultedSuccess(
          context,
          onOk: () {
            Navigator.of(context).pop();
            context.pop(MemberPenaltyActionOutcome.memberUpdated);
          },
        );
      },
    );
  }

  void _promptRemoveMember() {
    showRemoveMemberConfirm(
      context,
      memberName: widget.member.name,
      onConfirmed: _removeMember,
    );
  }

  void _promptMarkDefaulted() {
    showMarkDefaultedConfirm(context, onConfirmed: _markDefaulted);
  }

  @override
  Widget build(BuildContext context) {
    final showFooter = _showRemoveMember || _showMarkAsDefaulted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: AppStrings.penaltyActionTitle,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            SizedBox(height: 8.h),
            const Expanded(
              child: SingleChildScrollView(child: PenaltyActionContent()),
            ),
            if (showFooter)
              PenaltyActionFooter(
                showRemoveMember: _showRemoveMember,
                showMarkAsDefaulted: _showMarkAsDefaulted,
                onRemoveMember: _promptRemoveMember,
                onMarkDefaulted: _promptMarkDefaulted,
                isRemoveMemberLoading: _isRemoving,
                isMarkDefaultedLoading: _isMarkingDefaulted,
              ),
          ],
        ),
      ),
    );
  }
}
