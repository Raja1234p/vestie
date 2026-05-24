import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';

/// Full-screen background image; wrap [Scaffold] (or route root) as [child].
///
/// Image is anchored to the top (under the status bar) with [BoxFit.fitWidth],
/// not [BoxFit.cover], so the asset keeps its aspect ratio from the top edge.
final class UserVffProfileBackground extends StatelessWidget {
  final Widget child;

  const UserVffProfileBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          image: DecorationImage(
            image: AssetImage(AppAssets.vffProfileBackground),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}