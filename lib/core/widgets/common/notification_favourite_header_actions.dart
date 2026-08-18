import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:showcaseview/showcaseview.dart';
import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/showcase/app_showcase.dart';

/// Notification bell + favourite (VFF hub) for Home / Discover headers.
/// Both assets render at 32×32 inside equal square hit targets, vertically aligned.
class NotificationFavouriteHeaderActions extends StatelessWidget {
  /// Home-only ShowcaseView target. Discover must omit this so the key is unique.
  final GlobalKey? vffShowcaseKey;

  const NotificationFavouriteHeaderActions({
    super.key,
    this.vffShowcaseKey,
  });

  @override
  Widget build(BuildContext context) {
    const extent = 32.0;
    Widget vffButton = _SquareIconTap(
      extent: extent,
      onTap: () => context.push(AppRoutes.userVffMain),
      child: SvgPicture.asset(
        AppAssets.headerVffHub,
        width: extent,
        height: extent,
        fit: BoxFit.contain,
      ),
    );
    final showcaseKey = vffShowcaseKey;
    if (showcaseKey != null) {
      vffButton = AppShowcase.highlight(
        key: showcaseKey,
        title: AppStrings.showcaseDashboardVffTitle,
        description: AppStrings.showcaseDashboardVffBody,
        tooltipPosition: TooltipPosition.bottom,
        child: vffButton,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SquareIconTap(
          extent: extent,
          onTap: () => context.push(AppRoutes.notifications),
          child: SvgPicture.asset(
            AppAssets.headerNotification,
            width: extent,
            height: extent,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: 8.w),
        vffButton,
      ],
    );
  }
}

class _SquareIconTap extends StatelessWidget {
  const _SquareIconTap({
    required this.extent,
    required this.onTap,
    required this.child,
  });

  final double extent;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: extent,
        height: extent,
        child: Center(child: child),
      ),
    );
  }
}
