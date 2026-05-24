import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';

/// Accept / Join (lavender) + Decline (white, `#D9D9D9` border) — hub request cards.
class UserVffHubRequestActionButtons extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onDecline;
  final bool isPrimaryLoading;
  final bool isDeclineLoading;

  const UserVffHubRequestActionButtons({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onDecline,
    this.isPrimaryLoading = false,
    this.isDeclineLoading = false,
  });

  static const _radius = 8.0;
  static const _buttonHeight = 30.0;

  @override
  Widget build(BuildContext context) {
    final height = _buttonHeight.h;
    final busy = isPrimaryLoading || isDeclineLoading;

    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: primaryLabel,
            height: height,
            hasShadow: false,
            useGradient: false,
            isLoading: isPrimaryLoading,
            isSecondary: true,
            borderRadius: _radius.r,
            secondaryFillColor: AppColors.purple400,
            secondaryBorderColor: Colors.transparent,
            secondaryLabelColor: AppColors.grey1100,
            secondaryLabelFontWeight: FontWeight.w600,
            labelFontSize: 13.sp,
            onPressed: busy ? null : onPrimary,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: AppButton(
            text: AppStrings.btnDecline,
            height: height,
            hasShadow: false,
            useGradient: false,
            isLoading: isDeclineLoading,
            isSecondary: true,
            borderRadius: _radius.r,
            secondaryFillColor: AppColors.surface,
            secondaryBorderColor: AppColors.neutral400,
            secondaryLabelColor: AppColors.grey1100,
            secondaryLabelFontWeight: FontWeight.w600,
            labelFontSize: 13.sp,
            onPressed: busy ? null : onDecline,
          ),
        ),
      ],
    );
  }
}
