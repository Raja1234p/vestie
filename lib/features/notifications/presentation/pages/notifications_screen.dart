import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_shimmer.dart';
import '../../../../core/widgets/common/app_purple_dashed_line.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                ProfileSubHeader(title: AppStrings.notificationsTitle),
                Expanded(
                  child: state.loading
                      ? const NotificationListShimmer()
                      : state.items.isEmpty
                          ? const _EmptyNotifications()
                          : _NotificationListView(
                              items: state.items,
                              usedFallback: state.usedFallback,
                            ),
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
              width: 200.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            Text(
              AppStrings.notificationEmptyTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.grey1100,
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
  const _NotificationListView({
    required this.items,
    required this.usedFallback,
  });

  final List<NotificationListEntry> items;
  final bool usedFallback;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(0, 12.h, 0, 32.h),
      itemCount: items.length,
      separatorBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: const AppPurpleDashedLine(),
      ),
      itemBuilder: (context, i) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _NotificationListTile(
              item: items[i],
              onTap: usedFallback
                  ? null
                  : () => context
                      .read<NotificationsCubit>()
                      .markAsRead(items[i].id),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  const _NotificationListTile({
    required this.item,
    this.onTap,
  });

  final NotificationListEntry item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: item.isRead ? AppColors.grey100 : AppColors.purple100,
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
                  color: AppColors.navInactive,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          item.timeLabel,
          style: GoogleFonts.lato(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.navInactive,
          ),
        ),
      ],
      ),
    );
  }
}
