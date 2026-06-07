import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/ios_numeric_keyboard_input.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Label / field / primary button primitives for Vacation & Emergency member flows only.
/// Styling mirrors the leader wizard widgets without importing that feature.
class MemberFundFieldLabel extends StatelessWidget {
  final String text;

  const MemberFundFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: AppText(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textBody,
        ),
      ),
    );
  }
}

/// Single-line / multi-line text field with Vestie chrome.
class MemberFundTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;
  final String? errorText;

  const MemberFundTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.onSubmitted,
    this.suffixIcon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final isMultiline = maxLines > 1;
    final effectiveKeyboardType = IosNumericKeyboardInput.effectiveKeyboardType(
      keyboardType: keyboardType,
      isMultiline: isMultiline,
      textInputAction: textInputAction,
    );
    final effectiveTextInputAction = isMultiline
        ? (textInputAction == TextInputAction.done
              ? TextInputAction.done
              : TextInputAction.newline)
        : textInputAction;
    final effectiveInputFormatters =
        IosNumericKeyboardInput.effectiveFormatters(
          keyboardType: keyboardType,
          isMultiline: isMultiline,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
        );
    final disableTextAssist = IosNumericKeyboardInput.shouldDisableTextAssist(
      keyboardType: keyboardType,
      isMultiline: isMultiline,
      textInputAction: textInputAction,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.searchBarBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.inputFieldBorder,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted ??
                ((_) {
                  if (textInputAction == TextInputAction.done) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                }),
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            maxLines: maxLines,
            keyboardType: effectiveKeyboardType,
            textInputAction: effectiveTextInputAction,
            autocorrect: !disableTextAssist,
            enableSuggestions: !disableTextAssist,
            textCapitalization: disableTextAssist
                ? TextCapitalization.none
                : TextCapitalization.sentences,
            inputFormatters: effectiveInputFormatters.isEmpty
                ? null
                : effectiveInputFormatters,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.inputFieldText,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.authHint,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: AppText(
              errorText!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 11.sp,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// Full-width primary pill matching wizard “Next”.
class MemberFundPrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const MemberFundPrimaryButton({
    super.key,
    required this.onPressed,
    this.label = AppStrings.btnNext,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(text: label, onPressed: onPressed);
  }
}
