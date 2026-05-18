import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_numpad.dart';
import 'package:vestie/core/widgets/common/app_text.dart';

/// Figma amount modal — question, value, Continue, numpad (shared across flows).
class AppAmountEntrySheetContent extends StatelessWidget {
  final String title;
  final String amountDisplay;
  final bool canContinue;
  final VoidCallback onClose;
  final VoidCallback? onContinue;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const AppAmountEntrySheetContent({
    super.key,
    required this.title,
    required this.amountDisplay,
    required this.canContinue,
    required this.onClose,
    required this.onContinue,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: AppDimens.v12),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.p20,
              vertical: AppDimens.v12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: onClose,
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      AppAssets.iconCreateProjectSheetClose,
                      width: AppDimens.iconLarge,
                      height: AppDimens.iconLarge,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(
                  height: AppDimens.createProjectAmountSheetIconTitleVerticalGap,
                ),
                AppText(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.createProjectAmountSheetTitle,
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimens.createProjectAmountSheetTitleValueGap),
          AppText(
            amountDisplay,
            textAlign: TextAlign.center,
            style: AppTextStyles.createProjectAmountSheetValue,
          ),
          SizedBox(height: AppDimens.v28),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.p24),
            child: AppButton(
              text: AppStrings.btnContinue,
              onPressed: canContinue ? onContinue : null,
            ),
          ),
          SizedBox(height: AppDimens.v16),
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.r16),
            ),
            child: AppNumpad(
              onDigit: onDigit,
              onBackspace: onBackspace,
            ),
          ),
        ],
      ),
    );
  }
}
