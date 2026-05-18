import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Dev/preview control on live investment detail (mirrors success-vote preview).
class InvestmentDetailPreviewButton extends StatelessWidget {
  final VoidCallback onPressed;

  const InvestmentDetailPreviewButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        child: AppText(
          AppStrings.btnPreviewCompletedInvestment,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
        ),
      ),
    );
  }
}
