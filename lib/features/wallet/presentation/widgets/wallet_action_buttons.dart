import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';

/// Deposit (purple gradient pill) + Withdraw (white outline pill) — Figma wallet tab.
class WalletActionButtons extends StatelessWidget {
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  const WalletActionButtons({
    super.key,
    required this.onDeposit,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final radius = AppDimens.walletActionButtonRadius;
    final height = AppDimens.walletActionButtonHeight;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: AppStrings.btnDepositFunds,
              onPressed: onDeposit,
              hasShadow: true,
              useGradient: true,
              borderRadius: radius,
              height: height,
              labelFontSize: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppButton(
              text: AppStrings.btnWithdrawFunds,
              onPressed: onWithdraw,
              isSecondary: true,
              hasShadow: false,
              useGradient: false,
              borderRadius: radius,
              height: height,
              labelFontSize: 16.sp,
              secondaryFillColor: AppColors.surface,
              secondaryBorderColor: AppColors.primary,
              secondaryLabelColor: AppColors.grey900,
              secondaryLabelFontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
