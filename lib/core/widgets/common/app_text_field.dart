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
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1 || minLines > 1;
    final effectiveKeyboardType =
        isMultiline ? TextInputType.multiline : keyboardType;
    // Multiline fields default to Enter for new lines; pass [textInputAction:
    // TextInputAction.done] to show a Done key and dismiss on submit instead.
    final effectiveTextInputAction = isMultiline
        ? (textInputAction == TextInputAction.done
            ? TextInputAction.done
            : TextInputAction.newline)
        : textInputAction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.authLabel,
              ),
        ),
        SizedBox(height: 10.h),
        TextField(
          focusNode: focusNode,
          controller: controller,
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
            fontSize: 14.sp,
            color: AppColors.authSocialText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 14.sp,
              color: AppColors.authHint,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.authInputBg,
            counterText: '',
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: _border(AppColors.authInputBorder, 1),
            enabledBorder: _border(AppColors.authInputBorder, 1),
            focusedBorder: _border(AppColors.authLink, 1.5),
            errorBorder: _border(AppColors.error, 1),
            focusedErrorBorder: _border(AppColors.error, 1.5),
          ),
        ),
        if (errorText != null) ...[
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
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: color, width: width),
      );
}
