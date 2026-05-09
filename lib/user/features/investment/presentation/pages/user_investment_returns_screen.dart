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

/// “My Investment Returns” listing (UI mock).
class UserInvestmentReturnsScreen extends StatelessWidget {
  final UserInvestmentUiSnapshot snapshot;

  const UserInvestmentReturnsScreen({super.key, required this.snapshot});

  static String _money(num n) =>
      NumberFormat('#,##0.00', 'en_US').format(n);

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
                    AppText(
                      '\$${_money(snapshot.totalReturnsUsd)}',
                      style: GoogleFonts.lato(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AppText(
                      AppStrings.userInvestmentInvestedAmountLabel,
                      style: GoogleFonts.lato(
                        fontSize: 13.sp,
                        color: AppColors.textBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppText(
                      '\$${_money(snapshot.investedAmountUsd)}',
                      style: GoogleFonts.lato(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    AppText(
                      AppStrings.userInvestmentReturnsHistoryTitle,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.grey1100,
                      ),
                    ),
                    SizedBox(height: 12.h),
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
                          for (var i = 0; i < snapshot.returnsHistory.length; i++)
                            Column(
                              children: [
                                ListTile(
                                  title: AppText(
                                    snapshot.returnsHistory[i].periodLabel,
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  trailing: AppText(
                                    '+\$${_money(snapshot.returnsHistory[i].amount)}',
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.txPositive,
                                    ),
                                  ),
                                ),
                                if (i < snapshot.returnsHistory.length - 1)
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
