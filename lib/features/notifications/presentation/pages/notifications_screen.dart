import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_error_view.dart';
import '../../../../core/widgets/common/app_loading_overlay.dart';
import '../../../../core/widgets/common/app_shimmer.dart';
import '../../../../core/widgets/common/app_purple_dashed_line.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../profile/presentation/widgets/profile_sub_header.dart';
import '../../domain/entities/notification_list_entry.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../cubit/notification_unread_cubit.dart';
import '../widgets/notification_unread_badge.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (max - offset <= 200) {
      context.read<NotificationsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsCubit, NotificationsState>(
      listenWhen: (previous, current) =>
          previous.unreadCount != current.unreadCount,
      listener: (context, state) {
        context.read<NotificationUnreadCubit>().setCount(state.unreadCount);
      },
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        buildWhen: (previous, current) =>
            previous.loading != current.loading ||
            previous.loadingMore != current.loadingMore ||
            previous.items != current.items ||
            previous.unreadCount != current.unreadCount ||
            previous.error != current.error ||
            previous.silentRefreshing != current.silentRefreshing ||
            previous.hasMore != current.hasMore,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: PostAuthGradientBackground(
              child: AppLoadingOverlay(
                isLoading: state.silentRefreshing,
                child: Column(
                  children: [
                    ProfileSubHeader(
                      title: AppStrings.notificationsTitle,
                      trailing: state.unreadCount > 0
                          ? NotificationUnreadBadge(count: state.unreadCount)
                          : null,
                    ),
                    Expanded(child: _buildBody(context, state)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationsState state) {
    if (state.loading) {
      return const NotificationListShimmer();
    }
    if (state.hasLoadError) {
      return AppErrorView(
        message: state.error,
        onRetry: () => context.read<NotificationsCubit>().load(),
      );
    }
    if (state.isEmptySuccess) {
      return const _EmptyNotifications();
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<NotificationsCubit>().load(),
      child: _NotificationListView(
        controller: _scrollController,
        items: state.items,
        loadingMore: state.loadingMore,
        hasMore: state.hasMore,
        interactionsEnabled: !state.silentRefreshing,
      ),
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
              AppAssets.notificationsEmpty,
              width: 200.w,
              fit: BoxFit.contain,
              cacheWidth: (200.w * MediaQuery.devicePixelRatioOf(context))
                  .round(),
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
    required this.controller,
    required this.items,
    required this.loadingMore,
    required this.hasMore,
    required this.interactionsEnabled,
  });

  final ScrollController controller;
  final List<NotificationListEntry> items;
  final bool loadingMore;
  final bool hasMore;
  final bool interactionsEnabled;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(0, 0, 0, 32.h),
      itemCount: items.length + (loadingMore ? 1 : 0),
      separatorBuilder: (context, index) {
        if (index >= items.length - 1) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: const AppPurpleDashedLine(),
        );
      },
      itemBuilder: (context, i) {
        if (i >= items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _NotificationListTile(
              item: items[i],
              onTap: interactionsEnabled && !items[i].isRead
                  ? () => context.read<NotificationsCubit>().markAsRead(
                      items[i].id,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  const _NotificationListTile({required this.item, required this.onTap});

  final NotificationListEntry item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;

    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return RepaintBoundary(
      child: Material(
        color: isUnread
            ? AppColors.purple100.withValues(alpha: 0.45)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: isUnread
                            ? AppColors.purple200
                            : AppColors.grey100,
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
                          cacheWidth: (40.w * devicePixelRatio).round(),
                          cacheHeight: (40.w * devicePixelRatio).round(),
                        ),
                      ),
                    ),
                    if (isUnread)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: AppColors.purple900,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
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
                          fontWeight: isUnread
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isUnread
                              ? AppColors.grey1100
                              : AppColors.navInactive,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.body,
                        maxLines: 12,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: isUnread
                              ? AppColors.grey900
                              : AppColors.navInactive,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.timeLabel,
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        fontWeight: isUnread
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isUnread
                            ? AppColors.purple900
                            : AppColors.navInactive,
                      ),
                    ),
                    if (isUnread) ...[
                      SizedBox(height: 6.h),
                      Text(
                        'New',
                        style: GoogleFonts.lato(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.purple900,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
