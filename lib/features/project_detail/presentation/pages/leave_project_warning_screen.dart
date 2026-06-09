import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/services/home_project_list_sync.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_failure_dialog.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/common/centered_hero_status_block.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import '../navigation/open_project_from_card.dart';
import '../widgets/leave_project_destructive_button.dart';
import '../widgets/leave_project_dialogs.dart';

/// Leave project warning — failure hero, confirm dialog, API, then success dialog.
class LeaveProjectWarningScreen extends StatefulWidget {
  final LeaveProjectRouteArgs args;

  const LeaveProjectWarningScreen({super.key, required this.args});

  @override
  State<LeaveProjectWarningScreen> createState() =>
      _LeaveProjectWarningScreenState();
}

class _LeaveProjectWarningScreenState extends State<LeaveProjectWarningScreen> {
  bool _dialogOpen = false;

  Future<void> _onLeaveProjectPressed() async {
    if (_dialogOpen) return;
    setState(() => _dialogOpen = true);

    final left = await showLeaveProjectConfirmDialog(
      context,
      onConfirm: () async {
        final result = await ServiceLocator.instance.leaveProjectUseCase(
          projectId: widget.args.projectId,
        );
        return result.fold(
          (failure) {
            if (mounted) {
              AppFailureDialog.show(
                context,
                message: failure.message.isNotEmpty
                    ? failure.message
                    : AppStrings.errorGeneric,
              );
            }
            return false;
          },
          (_) => true,
        );
      },
    );

    if (!mounted) return;
    setState(() => _dialogOpen = false);
    if (!left) return;

    HomeProjectListSync.recordProjectLeft(widget.args.projectId);
    await showLeaveProjectSuccessDialog(context);
    if (!mounted) return;
    popAfterLeaveProjectSuccess(
      context,
      refreshHomeOnPop: widget.args.refreshHomeOnPop,
      refreshDiscoverOnPop: widget.args.refreshDiscoverOnPop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: CenteredHeroStatusBlock(
                imageAsset: AppAssets.statusFailure,
                headline: AppStrings.leaveProjectWarningTitle,
                body: AppStrings.leaveProjectWarningBody,
                bodyFontSize: 20,
                bodyColor: AppColors.grey900,
              ),
            ),
          ),
          FlowScreenFooter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LeaveProjectDestructiveButton(
                  label: AppStrings.leaveProjectWarningTitle,
                  isLoading: _dialogOpen,
                  onPressed: _dialogOpen ? null : _onLeaveProjectPressed,
                ),
                SizedBox(height: 12.h),
                AppOutlineNeutralButton(
                  label: AppStrings.btnCancel,
                  borderless: true,
                  onPressed: _dialogOpen ? () {} : () => context.pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
