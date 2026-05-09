import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

import '../models/user_investment_ui_snapshot.dart';

/// Contribution ledger for the pooled project (mock data).
class UserProjectFundsHistoryScreen extends StatelessWidget {
  final UserInvestmentUiSnapshot snapshot;

  const UserProjectFundsHistoryScreen({super.key, required this.snapshot});

  static String _money(num n) =>
      NumberFormat('#,##0', 'en_US').format(n);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: AppStrings.userInvestmentFundsHistoryTitle,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      AppStrings.userInvestmentTotalFundsLabel,
                      style: GoogleFonts.lato(
                        fontSize: 13.sp,
                        color: AppColors.textBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      '\$${_money(snapshot.totalProjectFundsUsd)}',
                      style: GoogleFonts.lato(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color:
                              AppColors.cardBorder.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < snapshot.fundsHistory.length; i++)
                            Column(
                              children: [
                                ListTile(
                                  title: AppText(
                                    snapshot.fundsHistory[i].memberName,
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  subtitle: AppText(
                                    snapshot.fundsHistory[i].dateLabel,
                                    style: GoogleFonts.lato(
                                      fontSize: 12.sp,
                                      color: AppColors.textBody,
                                    ),
                                  ),
                                  trailing: AppText(
                                    '+\$${_money(snapshot.fundsHistory[i].amount)}',
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15.sp,
                                      color: AppColors.txPositive,
                                    ),
                                  ),
                                ),
                                if (i < snapshot.fundsHistory.length - 1)
                                  const Divider(
                                    height: 1,
                                    color: AppColors.cardBorder,
                                  ),
                              ],
                            ),
                        ],
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
