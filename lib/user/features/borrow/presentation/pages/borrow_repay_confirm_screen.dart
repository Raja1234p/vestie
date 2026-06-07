import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/borrow_repay_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';

import '../widgets/borrow_repay_confirm_section.dart';

/// Borrow repay confirm — after payment method selection (Figma).
class BorrowRepayConfirmScreen extends StatelessWidget {
  final BorrowRepayConfirmRouteArgs args;

  const BorrowRepayConfirmScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostAuthHeader(
              title: AppStrings.repayScreenTitle,
              padding: EdgeInsets.fromLTRB(
                AppDimens.p16,
                AppDimens.v10,
                AppDimens.p16,
                0,
              ),
              leading: AppBackButton(
                onPressed: context.pop,
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(child: BorrowRepayConfirmSection(args: args)),
            FlowScreenFooter(
              child: AppButton(
                text: AppStrings.btnConfirmRepay,
                useGradient: false,
                hasShadow: false,
                color: AppColors.purple700,
                borderRadius: 12.r,
                onPressed: () => context.pushReplacement(
                  AppRoutes.borrowRepaySuccess,
                  extra: args,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
