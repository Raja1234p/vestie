import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/route_args/borrow_repay_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../navigation/borrow_repay_navigation.dart';

/// Borrow repay success (Figma).
class BorrowRepaySuccessScreen extends StatelessWidget {
  final BorrowRepayConfirmRouteArgs args;

  const BorrowRepaySuccessScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final amount = AppFormatters.formatCurrency(args.totalRepayment);

    final subtitle = args.successMessage?.trim().isNotEmpty == true
        ? args.successMessage!
        : AppStrings.borrowRepaySuccessBody(amount, args.projectName);

    return AppSuccessScreen(
      title: AppStrings.repaySentSuccessTitle,
      titleColor: AppColors.grey1000,
      subtitleWidget: AppText(
        subtitle,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral1200,
          height: 1.35,
        ),
      ),
      buttonText: AppStrings.btnDone,
      onButtonPressed: () => BorrowRepayNavigation.finishRepayFlow(context),
    );
  }
}
