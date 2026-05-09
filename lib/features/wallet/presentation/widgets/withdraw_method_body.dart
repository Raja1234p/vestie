import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/wallet/domain/withdraw_delivery_method.dart';
import 'withdraw_method_option_card.dart';

/// Standard vs instant withdrawal rail picker (Figma: Withdraw Method).
class WithdrawMethodBody extends StatelessWidget {
  final WithdrawDeliveryMethod selected;
  final ValueChanged<WithdrawDeliveryMethod> onSelect;
  final VoidCallback onContinue;

  const WithdrawMethodBody({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppDimens.v8),
          WithdrawMethodOptionCard(
            selected: selected == WithdrawDeliveryMethod.standard,
            iconAsset: AppAssets.iconDollarCircle,
            title: AppStrings.withdrawStandardTitle,
            subtitle: AppStrings.withdrawStandardSubtitle,
            onTap: () => onSelect(WithdrawDeliveryMethod.standard),
          ),
          SizedBox(height: AppDimens.v12),
          WithdrawMethodOptionCard(
            selected: selected == WithdrawDeliveryMethod.instant,
            iconAsset: AppAssets.iconLightning,
            title: AppStrings.withdrawInstantTitle,
            subtitle: AppStrings.withdrawInstantSubtitle,
            onTap: () => onSelect(WithdrawDeliveryMethod.instant),
          ),
          SizedBox(height: AppDimens.v20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSvgIcon(
                assetPath: AppAssets.iconInfo,
                size: AppDimens.iconSmall,
                color: AppColors.textBody,
              ),
              SizedBox(width: AppDimens.p8),
              Expanded(
                child: AppText(
                  AppStrings.withdrawFeeDisclaimerLine,
                  style: GoogleFonts.lato(
                    fontSize: 12.sp,
                    color: AppColors.textBody,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          AppButton(
            text: AppStrings.btnContinue,
            onPressed: onContinue,
          ),
          SizedBox(height: AppDimens.v16),
        ],
      ),
    );
  }
}
