import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_button.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: AppStrings.btnDepositFunds,
              onPressed: onDeposit,
              hasShadow: true, // Specific shadow for Deposit
              height: 43.h,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppButton(
              text: AppStrings.btnWithdrawFunds,
              onPressed: onWithdraw,
              isSecondary: true,
              height: 43.h,
            ),
          ),
        ],
      ),
    );
  }
}
