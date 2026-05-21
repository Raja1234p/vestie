import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/features/wallet/domain/withdraw_delivery_method.dart';
import 'withdraw_instant_option_card.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(AppDimens.p16, AppDimens.v8, AppDimens.p16, 0),
            children: [
              WithdrawMethodOptionCard(
                selected: selected == WithdrawDeliveryMethod.standard,
                iconAsset: AppAssets.iconDollarCircle,
                title: AppStrings.withdrawStandardTitle,
                subtitle: AppStrings.withdrawStandardSubtitle,
                onTap: () => onSelect(WithdrawDeliveryMethod.standard),
              ),
              SizedBox(height: AppDimens.v12),
              WithdrawInstantOptionCard(
                selected: selected == WithdrawDeliveryMethod.instant,
                onTap: () => onSelect(WithdrawDeliveryMethod.instant),
              ),
            ],
          ),
        ),
        FlowScreenFooter(
          child: AppButton(
            text: AppStrings.btnContinue,
            onPressed: onContinue,
          ),
        ),
      ],
    );
  }
}
