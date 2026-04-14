import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final ValueChanged<String>? onChanged;

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
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.authLabel,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLength: maxLength,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.authSocialText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
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
          Text(
            errorText!,
            style: GoogleFonts.inter(
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
