import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import '../widgets/mark_project_successful_widgets.dart';

class MarkProjectSuccessfulScreen extends StatelessWidget {
  final String projectId;
  final int memberCount;
  final ProjectCategory projectCategory;

  const MarkProjectSuccessfulScreen({
    super.key,
    required this.projectId,
    required this.memberCount,
    required this.projectCategory,
  });

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
                    const MarkSuccessfulHeroCard(),
                    SizedBox(height: 22.h),
                    AppText(
                      AppStrings.markSuccessfulIntro1,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        height: 1.5,
                        color: AppColors.grey1100,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    AppText(
                      AppStrings.markSuccessfulIntro2,
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
          FlowScreenFooter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  text: AppStrings.menuMarkSuccessful,
                  onPressed: () {
                    context.push(
                      AppRoutes.votingWindow,
                      extra: VotingWindowRouteArgs(
                        projectId: projectId,
                        projectCategory: projectCategory,
                      ),
                    );
                  },
                  useGradient: false,
                  hasShadow: false,
                  color: AppColors.green800,
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
        ],
      ),
    );
  }
}
