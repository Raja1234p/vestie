import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.lato(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.lato(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.lato(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.lato(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.lato(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.surface,
      );

  /// Create project amount sheet — question above amount (Figma #5E5783, 22, w600).
  static TextStyle get createProjectAmountSheetTitle => GoogleFonts.lato(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.grey800,
      );

  /// Dollar amount line on create-project amount step.
  static TextStyle get createProjectAmountSheetValue => GoogleFonts.lato(
        fontSize: 36.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.grey1100,
      );

  /// Project detail member row — name (Figma 16 / w600 / black).
  static TextStyle get projectMemberName => GoogleFonts.lato(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.projectMemberAvatarInitials,
      );

  static TextStyle get projectMemberAddFriend => GoogleFonts.lato(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral1200,
      );

  /// Home / discover section headers (Figma 18 / w700).
  static TextStyle get homeSectionTitle => GoogleFonts.lato(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
}
