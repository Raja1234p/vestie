import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../profile/presentation/widgets/profile_sub_header.dart';
import '../../domain/entities/notification_list_entry.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// Forces the empty-state art for 5s on open, then shows list or real empty.
  bool _showIntroEmpty = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showIntroEmpty = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntroEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: PostAuthGradientBackground(
          child: Column(
            children: [
              ProfileSubHeader(title: AppStrings.notificationsTitle),
              const Expanded(child: _EmptyNotifications()),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                ProfileSubHeader(title: AppStrings.notificationsTitle),
                Expanded(
                  child: state.items.isEmpty
                      ? const _EmptyNotifications()
                      : _NotificationListView(items: state.items),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.emptyNotification,
              width: 220.w,
              height: 220.w,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            SizedBox(height: 32.h),
            Text(
              AppStrings.notificationEmptyTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.grey1100,
                height: 1.2,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              AppStrings.notificationEmptySubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.navInactive,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationListView extends StatelessWidget {
  const _NotificationListView({required this.items});

  final List<NotificationListEntry> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(0, 12.h, 0, 32.h),
      itemCount: items.length,
      separatorBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: const _DashedSeparator(),
      ),
      itemBuilder: (context, i) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _NotificationListTile(item: items[i]),
          ),
        );
      },
    );
  }
}

class _DashedSeparator extends StatelessWidget {
  const _DashedSeparator();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return CustomPaint(
          size: Size(c.maxWidth, 2),
          painter: const _DashedLinePainter(
            color: AppColors.purple300,
          ),
        );
      },
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 15;
    const gap = 6.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    var x = 0.0;
    final y = size.height * 0.5;
    while (x < size.width) {
      final end = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _NotificationListTile extends StatelessWidget {
  const _NotificationListTile({required this.item});

  final NotificationListEntry item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: AppColors.purple100,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: Image.asset(
              AppAssets.notificationRowIcon,
              width: 40.w,
              height: 40.w,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey1100,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey800,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 4.w),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 80.w),
          child: Text(
            item.timeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grey500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
