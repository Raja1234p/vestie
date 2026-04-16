import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Figma-accurate Auth text field.
/// Label sits ABOVE the field (not floating inside), with a white
/// rounded container directly on the lavender gradient background.
class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? errorText;
  final int? maxLength;
  final void Function(String)? onChanged;

  const AuthTextField({
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
        // ── Label ─────────────────────────────────────────
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.authLabel,
          ),
        ),
        SizedBox(height: 6.h),

        // ── Input ─────────────────────────────────────────
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLength: maxLength,
          onChanged: onChanged,
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.authSocialText, // dark (#1A1033) — inside white input box
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.lato(
              fontSize: 14.sp,
              color: AppColors.authHint,
              fontWeight: FontWeight.w400,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.authInputBg,
            counterText: '', // Hide maxLength counter
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.authInputBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.authInputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.authLink, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),

        // ── Inline Error ───────────────────────────────────
        if (errorText != null) ...[
          SizedBox(height: 4.h),
          Text(
            errorText!,
            style: GoogleFonts.lato(
              fontSize: 11.sp,
              color: AppColors.error,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
