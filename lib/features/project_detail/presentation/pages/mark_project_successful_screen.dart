import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_outline_neutral_button.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../widgets/mark_project_successful_widgets.dart';
import '../widgets/mark_successful_vote_dialog.dart';

class MarkProjectSuccessfulScreen extends StatelessWidget {
  final int memberCount;

  const MarkProjectSuccessfulScreen({
    super.key,
    required this.memberCount,
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
                    SizedBox(height: 14.h),
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
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    text: AppStrings.btnInitiateSuccessVote,
                    onPressed: () {
                      showStartSuccessVoteDialog(
                        context,
                        memberCount: memberCount,
                        onStarted: () {
                          if (!context.mounted) return;
                          context.pop();
                          AppSnackBar.showSuccess(
                            context,
                            AppStrings.successVoteStartedMessage,
                          );
                        },
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
      ),
    );
  }
}
