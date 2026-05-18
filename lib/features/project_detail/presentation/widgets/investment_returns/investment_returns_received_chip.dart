import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

/// Summary chip — “Received so far” / “Received share” (Figma #F8F7FA).
class InvestmentReturnsReceivedChip extends StatelessWidget {
  final String label;
  final double amountUsd;
  final Color amountColor;

  const InvestmentReturnsReceivedChip({
    super.key,
    required this.label,
    required this.amountUsd,
    this.amountColor = AppColors.neutral1200,
  });

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
            label,
            color: AppColors.neutral1200,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          AppText(
            '\$${InvestmentReturnsUiData.formatMoney(amountUsd)}',
            color: amountColor,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
