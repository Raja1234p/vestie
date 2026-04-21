import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

/// Reusable avatar circle that shows initials.
/// Used in: MemberRow, BorrowRequestCard, and any future list screen.
class AppAvatarCircle extends StatelessWidget {
  final String initials;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const AppAvatarCircle({
    super.key,
    required this.initials,
    this.size,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = size ?? 44.w;
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.purple200,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: GoogleFonts.lato(
          fontSize: fontSize ?? 16.sp,
          fontWeight: FontWeight.w800,
          color: textColor ?? AppColors.neutral1100,
        ),
      ),
    );
  }
}
