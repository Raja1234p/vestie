import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';

/// Purple splash backdrop shared by the native-to-Flutter handoff and [SplashScreen].
class SplashBrandBackdrop extends StatelessWidget {
  const SplashBrandBackdrop({
    super.key,
    this.logoWidth,
  });

  /// When null, scales to ~200 logical px on a 390-wide design (matches splash).
  final double? logoWidth;

  @override
  Widget build(BuildContext context) {
    final width = logoWidth ?? MediaQuery.sizeOf(context).width * (200 / 390);

    return ColoredBox(
      color: AppColors.splashGradientBottom,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.splashBackground,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          // Center(
          //   child: Padding(
          //     padding: const EdgeInsets.only(bottom: 16),
          //     child: SvgPicture.asset(
          //       AppAssets.splashLogo,
          //       width: width,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
