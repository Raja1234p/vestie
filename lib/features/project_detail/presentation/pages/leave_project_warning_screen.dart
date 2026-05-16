import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/common/centered_hero_status_block.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import '../widgets/leave_project_destructive_button.dart';
import '../widgets/leave_project_dialogs.dart';

/// Leave project warning — failure hero, then confirm + success [AppActionDialog]s.
class LeaveProjectWarningScreen extends StatelessWidget {
  final LeaveProjectRouteArgs args;

  const LeaveProjectWarningScreen({super.key, required this.args});

  void _onLeaveProject(BuildContext context) {
    showLeaveProjectConfirmDialog(
      context,
      onConfirm: () {
        if (!context.mounted) return;
        context.pop();
        if (context.mounted && context.canPop()) {
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: args.projectName,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: CenteredHeroStatusBlock(
                imageAsset: AppAssets.failureIcon,
                headline: AppStrings.leaveProjectWarningTitle,
                body: AppStrings.leaveProjectWarningBody,
                imageHeight: 96,
                bodyFontSize: 20,
                bodyColor: AppColors.grey900,
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LeaveProjectDestructiveButton(
                      label: AppStrings.leaveProjectWarningTitle,
                      onPressed: () => _onLeaveProject(context),
                    ),
                    SizedBox(height: 12.h),
                    AppOutlineNeutralButton(
                      label: AppStrings.btnCancel,
                      onPressed: () => context.pop(),
                      borderRadius: AppRadius.r8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
