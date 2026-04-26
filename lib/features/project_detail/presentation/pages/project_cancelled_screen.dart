import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_destructive_notice_bar.dart';
import '../../../../core/widgets/common/app_outline_neutral_button.dart';
import '../../../../core/widgets/text/app_text.dart';

class ProjectCancelledScreen extends StatelessWidget {
  final String projectName;

  const ProjectCancelledScreen({
    super.key,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              Image.asset(
                AppAssets.failureIcon,
                height: 140.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 24.h),
              AppText(
                AppStrings.projectCancelledTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey1100,
                ),
              ),
              SizedBox(height: 12.h),
              AppText(
                AppStrings.projectCancelledDescription(projectName),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  height: 1.5,
                  color: AppColors.grey800,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.h),
              AppDestructiveNoticeBar(
                text: AppStrings.defaultedNoRefundShort,
              ),
              const Spacer(),
              AppOutlineNeutralButton(
                label: AppStrings.btnBackToHome,
                onPressed: () => context.go(AppRoutes.dashboard),
                borderRadius: AppRadius.r8,
                borderColor: AppColors.backToHomeButtonBorder,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
