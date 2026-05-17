import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_failure_dialog.dart';
import 'package:vestie/core/widgets/common/app_loading_dialog.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/common/flow_hero_image_card.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import '../widgets/cancel_project_confirm_dialog.dart';

Future<void> _executeProjectCancel(
  BuildContext context, {
  required String projectId,
  required String projectName,
}) async {
  if (!context.mounted) return;
  final rootNav = Navigator.of(context, rootNavigator: true);

  AppLoadingDialog.show(context);

  final result = await ServiceLocator.instance.cancelProjectUseCase(
    projectId: projectId,
  );

  if (context.mounted && rootNav.canPop()) {
    rootNav.pop();
  }

  if (!context.mounted) return;

  result.fold(
    (failure) {
      AppFailureDialog.show(
        context,
        message: failure.message.isNotEmpty
            ? failure.message
            : AppStrings.errorGeneric,
      );
    },
    (_) {
      context.pushReplacement(
        AppRoutes.projectCancelled,
        extra: ProjectCancelledRouteArgs(projectName: projectName),
      );
    },
  );
}

class CancelProjectScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  final int membersWithUnpaidBorrows;

  const CancelProjectScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    this.membersWithUnpaidBorrows = 0,
  });

  @override
  State<CancelProjectScreen> createState() => _CancelProjectScreenState();
}

class _CancelProjectScreenState extends State<CancelProjectScreen> {
  bool _isCancelling = false;

  void _onCancelProjectPressed() {
    if (_isCancelling) return;
    showCancelProjectConfirmDialog(
      context,
      projectName: widget.projectName,
      onConfirm: () async {
        if (!mounted) return;
        setState(() => _isCancelling = true);
        await _executeProjectCancel(
          context,
          projectId: widget.projectId,
          projectName: widget.projectName,
        );
        if (mounted) setState(() => _isCancelling = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FlowHeroImageCard(
                      imageAsset: AppAssets.markCancel,
                      backgroundColor: AppColors.red100,
                      borderRadius: 10.r,
                      caption: AppStrings.cancelProjectHeroWarning,
                      captionColor: AppColors.red1000,
                      imageHeight: 200,
                      captionFontWeight: FontWeight.w600,
                      captionStyle: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.red900,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    AppText(
                      AppStrings.cancelProjectUnpaidBorrowsLine(
                        widget.membersWithUnpaidBorrows,
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        height: 1.5,
                        color: AppColors.grey1100,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    AppText(
                      AppStrings.cancelProjectRefundParagraph,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        height: 1.5,
                        color: AppColors.grey1100,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  text: AppStrings.menuCancelProject,
                  isLoading: _isCancelling,
                  onPressed: _isCancelling ? null : _onCancelProjectPressed,
                  useGradient: false,
                  hasShadow: false,
                  color: AppColors.red800,
                  borderRadius: AppRadius.r8,
                ),
                SizedBox(height: 12.h),
                AppOutlineNeutralButton(
                  label: AppStrings.btnNo,
                  onPressed: () {
                    if (_isCancelling) return;
                    context.pop();
                  },
                  borderRadius: AppRadius.r8,
                  borderColor: AppColors.grey700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
