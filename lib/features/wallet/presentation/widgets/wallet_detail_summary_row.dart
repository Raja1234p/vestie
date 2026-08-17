import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Single label/value row used on wallet confirm sheets.
class WalletDetailSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueChild;
  final Color? labelColor;
  final FontWeight labelWeight;
  final Color? valueColor;
  final FontWeight valueWeight;
  final double? labelFontSize;
  final double? valueFontSize;

  const WalletDetailSummaryRow({
    super.key,
    required this.label,
    this.value = '',
    this.valueChild,
    this.labelColor,
    this.labelWeight = FontWeight.w500,
    this.valueColor,
    this.valueWeight = FontWeight.w600,
    this.labelFontSize,
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
              fontSize: labelFontSize ?? 14.sp,
              fontWeight: labelWeight,
              color: labelColor ?? AppColors.grey700,
            ),
          ),
        ),
        valueChild ??
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
