import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_destructive_notice_bar.dart';
import 'package:vestie/core/widgets/common/failure_icon.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

class ProjectCancelledScreen extends StatelessWidget {
  final String projectName;

  const ProjectCancelledScreen({super.key, required this.projectName});

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FailureIcon(),
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          FlowScreenFooter(
            child: AppOutlineNeutralButton(
              label: AppStrings.btnBackToHome,
              onPressed: () =>
                  popProjectDetailNavigation(context, refreshHomeOnPop: true),
              borderRadius: AppRadius.r8,
              borderColor: AppColors.backToHomeButtonBorder,
            ),
          ),
        ],
      ),
    );
  }
}
