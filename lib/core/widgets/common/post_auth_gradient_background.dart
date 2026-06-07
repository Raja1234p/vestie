import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_dimens.dart';

/// Fixed-height gradient [Container] — same asset/layout as [HomeHeader].
class PostAuthGradientHeaderBand extends StatelessWidget {
  final Widget child;
  final double height;

  PostAuthGradientHeaderBand({
    super.key,
    required this.child,
    double? height,
  }) : height = height ?? AppDimens.postAuthHeaderHeight;

  static const decoration = BoxDecoration(
    image: DecorationImage(
      image: AssetImage(AppAssets.headerGradient),
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: decoration,
      child: child,
    );
  }
}

/// White gap below header band before body content (Home uses [AppDimens.homeContentTopGap]).
class PostAuthHeaderContentGap extends StatelessWidget {
  final double gap;

  const PostAuthHeaderContentGap({super.key, double? gap})
    : gap = gap ?? AppDimens.postAuthContentTopGap;

  @override
  Widget build(BuildContext context) => SizedBox(height: gap.h);
}

/// White page shell for post-auth screens (gradient is on header bands only).
class PostAuthGradientBackground extends StatelessWidget {
  final Widget child;

  const PostAuthGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Colors.white, child: child);
  }
}
