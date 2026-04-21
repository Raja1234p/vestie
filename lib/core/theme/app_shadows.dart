import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get primaryButton => [
        BoxShadow(
          color: AppColors.purple700.withValues(alpha: 0.36),
          blurRadius: 4.r,
          spreadRadius: 2.r,
          offset: const Offset(0, 0),
        ),
        BoxShadow(
          color: AppColors.purple900.withValues(alpha: 0.28),
          blurRadius: 4.r,
          offset: Offset(0, 5.h),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10.r,
          offset: Offset(0, 2.h),
        ),
      ];
}
