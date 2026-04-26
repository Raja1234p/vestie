import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/route_args/project_detail_flow_args.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_outline_neutral_button.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../widgets/user_success_vote_panels.dart';

/// Member: vote on whether the project was successful (Figma: banner, deadline,
/// stats, question, CTA, disclaimer — all in one scroll below header).
class UserSuccessVoteScreen extends StatelessWidget {
  final UserSuccessVoteArgs args;

  const UserSuccessVoteScreen({super.key, required this.args});

  void _submitVote(BuildContext context, {required bool voteForSuccess}) {
    context.pushReplacement(
      AppRoutes.userStatusFlow,
      extra: UserStatusFlowArgs(
        projectName: args.projectName,
        kind: voteForSuccess
            ? UserStatusFlowKind.markVotedSuccess
            : UserStatusFlowKind.markVotedIncomplete,
      ),
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
              leading: AppBackButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.dashboard);
                  }
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UserSuccessVotePanels(args: args),
                    SizedBox(height: 20.h),
                    AppText(
                      AppStrings.userSuccessVoteQuestion,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey1100,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    AppButton(
                      text: AppStrings.userSuccessVoteYes,
                      onPressed: () =>
                          _submitVote(context, voteForSuccess: true),
                      useGradient: true,
                      borderRadius: AppRadius.r24,
                    ),
                    SizedBox(height: 12.h),
                    AppOutlineNeutralButton(
                      label: AppStrings.userSuccessVoteNotYet,
                      onPressed: () =>
                          _submitVote(context, voteForSuccess: false),
                      borderRadius: AppRadius.r24,
                      borderColor: AppColors.primary,
                      labelColor: AppColors.primary,
                    ),
                    SizedBox(height: 10.h),
                    AppText(
                      AppStrings.userSuccessVoteFooter,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey600,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 8.h),
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
