import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

import 'investment_returns_distribution_card.dart';
import 'investment_returns_received_chip.dart';

/// Shared scroll body — summary row + payment history (member & leader).
class InvestmentReturnsScreenBody extends StatelessWidget {
  final InvestmentReturnsUiData data;
  final bool hasPinnedFooter;

  const InvestmentReturnsScreenBody({
    super.key,
    required this.data,
    this.hasPinnedFooter = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      data.primarySummaryLabel,
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
              InvestmentReturnsReceivedChip(
                label: data.receivedCardLabel,
                amountUsd: data.receivedSoFarUsd,
                amountColor: data.receivedCardAmountColor,
              ),
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
              defaultLeftColumnLabel: data.defaultLeftColumnLabel,
            ),
          ),
          SizedBox(height: hasPinnedFooter ? 16.h : 32.h),
        ],
      ),
    );
  }
}
