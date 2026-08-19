import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:showcaseview/showcaseview.dart';
import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/showcase/app_showcase.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/features/notifications/presentation/cubit/notification_unread_cubit.dart';
import 'package:vestie/features/notifications/presentation/cubit/notification_unread_state.dart';
import 'package:vestie/features/notifications/presentation/widgets/notification_unread_badge.dart';
import 'package:vestie/user/features/vff/presentation/cubit/vff_pending_cubit.dart';
import 'package:vestie/user/features/vff/presentation/cubit/vff_pending_state.dart';

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
    Widget vffButton = BlocBuilder<VffPendingCubit, VffPendingState>(
      buildWhen: (previous, current) =>
          previous.hasPending != current.hasPending,
      builder: (context, vffState) {
        return _SquareIconTap(
          extent: extent,
          onTap: () async {
            await context.push(AppRoutes.userVffMain);
            if (!context.mounted) return;
            await context.read<VffPendingCubit>().refresh();
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                AppAssets.headerVffHub,
                width: extent,
                height: extent,
                fit: BoxFit.contain,
              ),
              if (vffState.hasPending)
                Positioned(
                  top: -2.h,
                  right: -2.w,
                  child: Container(
                    key: const Key('vff_pending_dot'),
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppColors.purple900,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
        BlocBuilder<NotificationUnreadCubit, NotificationUnreadState>(
          buildWhen: (previous, current) =>
              previous.unreadCount != current.unreadCount,
          builder: (context, unreadState) {
            return _SquareIconTap(
              extent: extent,
              onTap: () async {
                await context.push(AppRoutes.notifications);
                if (!context.mounted) return;
                await context.read<NotificationUnreadCubit>().refresh();
              },
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssets.headerNotification,
                    width: extent,
                    height: extent,
                    fit: BoxFit.contain,
                  ),
                  if (unreadState.unreadCount > 0)
                    Positioned(
                      top: -2.h,
                      right: -4.w,
                      child: NotificationUnreadBadge(
                        count: unreadState.unreadCount,
                        style: NotificationUnreadBadgeStyle.iconOverlay,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        SizedBox(width: 12.w),
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
