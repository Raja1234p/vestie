import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// **Flow: Accept / Join** → “Invites Sent!” before returning to dashboard.
final class UserVffInvitesSentScreen extends StatelessWidget {
  final int inviteCount;
  final String projectName;

  const UserVffInvitesSentScreen({
    super.key,
    required this.inviteCount,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: AppDimens.screenHorizontalComfort,
            child: Column(
              children: [
                SizedBox(height: AppDimens.v48),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: AppDimens.illustrationLg,
                        height: AppDimens.illustrationLg,
                        child: Image.asset(
                          AppAssets.markSuccessfullProject,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: AppDimens.v24),
                      AppText(
                        AppStrings.userVffInviteSuccessTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.grey1100,
                        ),
                      ),
                      SizedBox(height: AppDimens.v14),
                      AppText(
                        AppStrings.userVffInviteSubtitle(inviteCount),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          color: AppColors.textBody,
                        ),
                      ),
                      SizedBox(height: AppDimens.v8),
                      AppText(
                        projectName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.grey1100,
                        ),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  text: AppStrings.btnDone,
                  useGradient: false,
                  color: AppColors.grey1200,
                  hasShadow: true,
                  onPressed: () => context.go(AppRoutes.dashboard),
                ),
                SizedBox(height: AppDimens.v24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
