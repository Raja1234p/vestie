import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_distribution_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_distribution/investment_distribution_breakdown_table.dart';

/// Leader distribution breakdown — summary, table, confirm (Figma).
class InvestmentDistributionScreen extends StatelessWidget {
  final InvestmentDistributionUiData data;

  const InvestmentDistributionScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: AppStrings.investmentDistributionScreenTitle,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      AppStrings.investmentDistributingLabel,
                      color: AppColors.neutral1200,
                      style: GoogleFonts.lato(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      '\$${data.formattedDistributeAmount}',
                      color: AppColors.neutral1200,
                      style: GoogleFonts.lato(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      AppStrings.investmentDistributingToMembers(
                        data.memberCount,
                      ),
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey800,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: AppText(
                        AppStrings.investmentRemainingToDistribute(
                          '\$${data.formattedRemaining}',
                        ),
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blue900,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    AppText(
                      AppStrings.labelBreakdown,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.grey1100,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    InvestmentDistributionBreakdownTable(members: data.members),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            FlowScreenFooter(
              child: AppButton(
                text: AppStrings.btnConfirmAndDistribute,
                onPressed: () =>
                    ProjectDetailNavigation.openFundsDistributedSuccess(
                      context,
                      distributionData: data,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
