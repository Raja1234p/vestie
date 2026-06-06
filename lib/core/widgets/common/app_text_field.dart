import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../text/app_text.dart';
import '../../theme/app_colors.dart';

/// Generic text field supporting email, password, and text modes.
/// Renders: [label] → [TextField] → [error text]
/// No state managed internally — all state driven by parent/Cubit.
class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? errorText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int minLines;
  final int maxLines;
  final FocusNode? focusNode;

  /// Shown on the same row as [label] (e.g. info icon) — optional.
  final Widget? labelTrailing;

  /// Horizontal gap between [label] text and [labelTrailing] (e.g. up to `10.w`).
  final double? labelTrailingGap;

  /// Space to the right of [labelTrailing] after label + icon.
  final double? labelTrailingEndGap;

  /// When set, overrides default label typography (e.g. create-project details).
  final TextStyle? labelStyle;

  /// When set, overrides default input fill ([AppColors.authInputBg]).
  final Color? fillColor;

  /// When set, overrides default hint style (e.g. ROI field).
  final TextStyle? hintStyle;

  /// When set with [suffixIcon], overrides M3’s default 48×48 suffix slot (shrinks small glyphs).
  final BoxConstraints? suffixIconConstraints;
  final bool readOnly;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.errorText,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.minLines = 1,
    this.maxLines = 1,
    this.focusNode,
    this.labelTrailing,
    this.labelTrailingGap,
    this.labelTrailingEndGap,
    this.labelStyle,
    this.fillColor,
    this.hintStyle,
    this.suffixIconConstraints,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1 || minLines > 1;
    final effectiveKeyboardType = isMultiline
        ? TextInputType.multiline
        : keyboardType;
    // Multiline fields default to Enter for new lines; pass [textInputAction:
    // TextInputAction.done] to show a Done key and dismiss on submit instead.
    final effectiveTextInputAction = isMultiline
        ? (textInputAction == TextInputAction.done
              ? TextInputAction.done
              : TextInputAction.newline)
        : textInputAction;

    final effectiveLabelStyle =
        labelStyle ??
        Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.authLabel,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelTrailing != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(label, style: effectiveLabelStyle),
              if (labelTrailingGap != null && labelTrailingGap! > 0)
                SizedBox(width: labelTrailingGap!),
              labelTrailing!,
              if (labelTrailingEndGap != null && labelTrailingEndGap! > 0)
                SizedBox(width: labelTrailingEndGap!),
            ],
          )
        else
          AppText(label, style: effectiveLabelStyle),
        SizedBox(height: 12.h),
        TextField(
          focusNode: focusNode,
          controller: controller,
          readOnly: readOnly,
          showCursor: true,
          obscureText: obscureText,
          keyboardType: effectiveKeyboardType,
          textInputAction: effectiveTextInputAction,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          minLines: minLines,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.inputFieldText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                hintStyle ??
                Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authHint,
                ),
            suffixIcon: suffixIcon,
            suffixIconConstraints: suffixIconConstraints,
            filled: true,
            fillColor: fillColor ?? AppColors.authInputBg,
            counterText: '',
            suffixIconColor: AppColors.inputFieldIcon,
            prefixIconColor: AppColors.inputFieldIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: _border(AppColors.inputFieldBorder, 1),
            enabledBorder: _border(AppColors.inputFieldBorder, 1),
            focusedBorder: _border(AppColors.inputFieldBorder, 1.5),
            disabledBorder: _border(AppColors.inputFieldBorder, 1),
            errorBorder: _border(AppColors.error, 1),
            focusedErrorBorder: _border(AppColors.error, 1.5),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          SizedBox(height: 4.h),
          AppText(
            errorText!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 11.sp,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: BorderSide(color: color, width: width),
  );
}
