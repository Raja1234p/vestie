import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized dimensions ensuring zero hardcoded numbers in widgets.
class AppDimens {
  AppDimens._();

  // Padding & Margins
  static double get p4 => 4.0.w;
  static double get p8 => 8.0.w;
  static double get p12 => 12.0.w;
  static double get p16 => 16.0.w; // Standard screen padding
  static double get p20 => 20.0.w;
  static double get p24 => 24.0.w;
  static double get p32 => 32.0.w;
  static double get p40 => 40.0.w;
  static double get p48 => 48.0.w;
  static double get p64 => 64.0.w;

  // Icon Sizes
  static double get iconSmall => 16.0.w;
  static double get iconMedium => 24.0.w;
  static double get iconLarge => 32.0.w;

  /// App bar / header back chevron (keep in sync with [AppBackButton]).
  static double get backIconSize => iconMedium;

  // Button Heights
  static double get buttonHeightSm => 40.0.h;
  static double get buttonHeightMd => 48.0.h;
  static double get buttonHeightLg => 56.0.h;
}

class AppRadius {
  AppRadius._();

  static double get r4 => 4.0.r;
  static double get r8 => 8.0.r;
  static double get r12 => 12.0.r;
  static double get r16 => 16.0.r;
  static double get r24 => 24.0.r;
  static double get r32 => 32.0.r;
  
  static double get button => 12.0.r; // Standard button radius
  static double get card => 16.0.r; // Standard card radius
}
