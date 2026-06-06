import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';

/// Leader success after confirming a fund distribution (Figma).
class InvestmentFundsDistributedSuccessScreen extends StatelessWidget {
  final InvestmentDistributionSuccessRouteArgs args;

  const InvestmentFundsDistributedSuccessScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = InvestmentReturnsUiData.formatMoney(args.amountUsd);

    return AppSuccessScreen(
      title: AppStrings.fundsDistributedSuccessTitle,
      subtitleWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text.rich(
          TextSpan(
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grey800,
              height: 1.35,
            ),
            children: [
              TextSpan(
                text: '\$$formattedAmount ',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: AppStrings.fundsDistributedSentToMembers(
                  args.memberCount,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      buttonText: AppStrings.btnBackToProject,
      onButtonPressed: () => ProjectDetailNavigation.popAfterFundsDistributed(
        context,
        projectId: args.projectId,
        projectName: args.projectName,
      ),
    );
  }
}
