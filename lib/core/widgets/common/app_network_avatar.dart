import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import 'app_network_image.dart';

/// Circle avatar: local pick → network URL → initials fallback.
class AppNetworkAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? localFile;
  final String initials;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppNetworkAvatar({
    super.key,
    this.imageUrl,
    this.localFile,
    required this.initials,
    this.size,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = size ?? 44.w;
    final hasImage =
        localFile != null || AppNetworkImage.isValidNetworkUrl(imageUrl);

    if (hasImage) {
      return ClipOval(
        child: AppNetworkImage(
          imageUrl: imageUrl,
          localFile: localFile,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          errorWidget: _initialsFallback(diameter),
        ),
      );
    }

    return _initialsFallback(diameter);
  }

  Widget _initialsFallback(double diameter) {
    final trimmed = initials.trim();
    final label = trimmed.isEmpty
        ? '?'
        : (trimmed.length >= 2
            ? trimmed.substring(0, 2).toUpperCase()
            : trimmed.substring(0, 1).toUpperCase());

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.purple200,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: fontSize ?? 16.sp,
          fontWeight: fontWeight ?? FontWeight.w800,
          color: textColor ?? AppColors.neutral1100,
        ),
      ),
    );
  }
}
