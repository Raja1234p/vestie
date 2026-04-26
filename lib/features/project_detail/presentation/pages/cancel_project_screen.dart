import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_outline_neutral_button.dart';
import '../../../../core/widgets/common/flow_hero_image_card.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/project_detail_route_args.dart';
import '../widgets/cancel_project_confirm_dialog.dart';

class CancelProjectScreen extends StatelessWidget {
  final String projectName;
  final int membersWithUnpaidBorrows;

  const CancelProjectScreen({
    super.key,
    required this.projectName,
    this.membersWithUnpaidBorrows = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FlowHeroImageCard(
                      imageAsset: AppAssets.markCancel,
                      backgroundColor: AppColors.red200,
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
                        membersWithUnpaidBorrows,
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
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      text: AppStrings.menuCancelProject,
                      onPressed: () {
                        showCancelProjectConfirmDialog(
                          context,
                          projectName: projectName,
                          onConfirm: () {
                            if (!context.mounted) return;
                            context.pushReplacement(
                              AppRoutes.projectCancelled,
                              extra: ProjectCancelledRouteArgs(
                                projectName: projectName,
                              ),
                            );
                          },
                        );
                      },
                      useGradient: false,
                      hasShadow: false,
                      color: AppColors.red800,
                      borderRadius: AppRadius.r8,
                    ),
                    SizedBox(height: 12.h),
                    AppOutlineNeutralButton(
                      label: AppStrings.btnNo,
                      onPressed: () => context.pop(),
                      borderRadius: AppRadius.r8,
                      borderColor: AppColors.grey700,
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
