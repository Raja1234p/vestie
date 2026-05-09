import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Single label/value row used on wallet confirm sheets.
class WalletDetailSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight valueWeight;
  final double? valueFontSize;

  const WalletDetailSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWeight = FontWeight.w600,
    this.valueFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppText(
            label,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              color: AppColors.textBody,
            ),
          ),
        ),
        AppText(
          value,
          style: GoogleFonts.lato(
            fontSize: valueFontSize ?? 14.sp,
            fontWeight: valueWeight,
            color: valueColor ?? AppColors.grey1100,
          ),
        ),
      ],
    );
  }
}
