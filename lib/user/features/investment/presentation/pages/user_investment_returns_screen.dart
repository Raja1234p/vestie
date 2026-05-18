import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

import '../widgets/investment_returns_distribution_card.dart';

/// “My Investment Returns” — contribution summary + payment history (Figma).
class UserInvestmentReturnsScreen extends StatelessWidget {
  final InvestmentReturnsUiData data;

  const UserInvestmentReturnsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: AppStrings.userInvestmentReturnsTitle,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                AppStrings.userInvestmentMyContributionLabel,
                                color: AppColors.neutral1200,
                                style: GoogleFonts.lato(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              AppText(
                                '\$${InvestmentReturnsUiData.formatMoney(data.myContributionUsd)}',
                                color: AppColors.neutral1200,
                                style: GoogleFonts.lato(
                                  fontSize: 36.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        _ReceivedSoFarCard(amountUsd: data.receivedSoFarUsd),
                      ],
                    ),
                    SizedBox(height: 28.h),
                    AppText(
                      AppStrings.userInvestmentPaymentHistoryTitle,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.grey1100,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...data.distributions.map(
                      (d) => InvestmentReturnsDistributionCard(
                        distribution: d,
                      ),
                    ),
                    SizedBox(height: 32.h),
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

class _ReceivedSoFarCard extends StatelessWidget {
  final double amountUsd;

  const _ReceivedSoFarCard({required this.amountUsd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.userInvestmentReceivedSoFarLabel,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral1200,
            ),
          ),
          SizedBox(height: 4.h),
          AppText(
            '\$${InvestmentReturnsUiData.formatMoney(amountUsd)}',
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral1200,
            ),
          ),
        ],
      ),
    );
  }
}
