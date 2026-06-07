import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';
import 'post_auth_gradient_background.dart';
import '../text/app_text.dart';

/// Title header: gradient [Container] band + consistent gap before body (Home parity).
class PostAuthHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;

  /// White space below the gradient band before body (default [AppDimens.postAuthContentTopGap]).
  final double contentTopGap;

  /// When false, parent applies top inset (legacy — prefer [applyTopSafeArea] true).
  final bool applyTopSafeArea;

  /// Gradient band height (default 130.h; Home/Discover use [AppDimens.homeHeaderHeight]).
  final double bandHeight;

  /// Vertically centers the title row in the band ([HomeHeader] / Discover parity).
  final bool centerTitleInBand;

  PostAuthHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.padding,
    this.titleStyle,
    double? contentTopGap,
    double? bandHeight,
    this.applyTopSafeArea = true,
    this.centerTitleInBand = false,
  })  : contentTopGap = contentTopGap ?? AppDimens.postAuthContentTopGap,
        bandHeight = bandHeight ?? AppDimens.postAuthHeaderHeight;

  @override
  Widget build(BuildContext context) {
    final titleRow = Padding(
      padding:
          padding ??
          (centerTitleInBand
              ? EdgeInsets.symmetric(horizontal: 16.w)
              : EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, SizedBox(width: 8.w)],
          Expanded(
            child: AppText(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  titleStyle ??
                  GoogleFonts.lato(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey1100,
                    letterSpacing: -0.5,
                  ),
            ),
          ),
          if (trailing != null) ...[SizedBox(width: 8.w), trailing!],
        ],
      ),
    );

    final alignedTitle = centerTitleInBand
        ? Align(alignment: Alignment.center, child: titleRow)
        : titleRow;

    final bandChild = applyTopSafeArea
        ? SafeArea(bottom: false, child: alignedTitle)
        : alignedTitle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PostAuthGradientHeaderBand(height: bandHeight, child: bandChild),
        if (contentTopGap > 0) PostAuthHeaderContentGap(gap: contentTopGap),
      ],
    );
  }
}
