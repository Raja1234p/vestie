import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';

/// Hub body skeleton — matches active top tab (My VFFs vs Requests).
class UserVffHubShimmer extends StatelessWidget {
  final bool requestsTab;

  const UserVffHubShimmer({super.key, this.requestsTab = false});

  @override
  Widget build(BuildContext context) {
    if (requestsTab) {
      return const UserVffHubRequestsTabShimmer();
    }
    return const UserVffHubMyVffsTabShimmer();
  }
}

/// My VFFs tab: connected list + sent outgoing rows.
class UserVffHubMyVffsTabShimmer extends StatelessWidget {
  const UserVffHubMyVffsTabShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppDimens.p18,
          0,
          AppDimens.p18,
          AppDimens.v28,
        ),
        children: [
          _sectionHeaderShimmer(width: 88.w),
          SizedBox(height: 10.h),
          for (var i = 0; i < 2; i++) ...[
            _connectionRowShimmer(trailingWide: false),
            SizedBox(height: AppDimens.v12),
          ],
          for (var i = 0; i < 2; i++) ...[
            _connectionRowShimmer(trailingWide: true),
            SizedBox(height: AppDimens.v12),
          ],
        ],
      ),
    );
  }
}

/// Requests tab: VFF requests + group invitations (no inner Received/Sent tabs).
class UserVffHubRequestsTabShimmer extends StatelessWidget {
  const UserVffHubRequestsTabShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppDimens.p18,
          0,
          AppDimens.p18,
          AppDimens.v28,
        ),
        children: [
          _sectionHeaderShimmer(width: 110.w, withAction: true),
          SizedBox(height: 10.h),
          for (var i = 0; i < 2; i++) ...[
            _inboxRequestCardShimmer(),
            SizedBox(height: AppDimens.v12),
          ],
          SizedBox(height: AppDimens.v14),
          _sectionHeaderShimmer(width: 130.w, withAction: true),
          SizedBox(height: 10.h),
          for (var i = 0; i < 2; i++) ...[
            _groupInviteCardShimmer(),
            SizedBox(height: AppDimens.v12),
          ],
        ],
      ),
    );
  }
}

Widget _sectionHeaderShimmer({
  required double width,
  bool withAction = false,
}) {
  return Row(
    children: [
      AppShimmer.box(width: width, height: 18.h, borderRadius: 4.r),
      const Spacer(),
      if (withAction)
        AppShimmer.box(width: 72.w, height: 14.h, borderRadius: 4.r),
    ],
  );
}

Widget _connectionRowShimmer({required bool trailingWide}) {
  return Container(
    padding: EdgeInsets.all(AppDimens.p16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      children: [
        AppShimmer.box(width: 40.r, height: 40.r, borderRadius: 20.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.box(width: 120.w, height: 16.h, borderRadius: 4.r),
              SizedBox(height: 4.h),
              AppShimmer.box(width: 100.w, height: 12.h, borderRadius: 4.r),
            ],
          ),
        ),
        AppShimmer.box(
          width: trailingWide ? 72.w : 22.w,
          height: trailingWide ? 28.h : 22.h,
          borderRadius: 10.r,
        ),
      ],
    ),
  );
}

Widget _inboxRequestCardShimmer() {
  return Container(
    padding: EdgeInsets.all(AppDimens.p16),
    decoration: _vffInboxListCardDecoration(),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer.box(width: 40.r, height: 40.r, borderRadius: 20.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.box(width: 120.w, height: 16.h, borderRadius: 4.r),
              SizedBox(height: 4.h),
              AppShimmer.box(width: 150.w, height: 12.h, borderRadius: 4.r),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: AppShimmer.box(
                      width: double.infinity,
                      height: 40.h,
                      borderRadius: 10.r,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AppShimmer.box(
                      width: double.infinity,
                      height: 40.h,
                      borderRadius: 10.r,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _vffFullListSectionTitleShimmer() {
  return Padding(
    padding: EdgeInsets.only(bottom: AppDimens.v16),
    child: AppShimmer.box(width: 160.w, height: 18.h, borderRadius: 4.r),
  );
}

/// [UserVffVffRequestsScreen] — matches loaded list (title + 16px card gaps).
final class UserVffIncomingRequestListShimmer extends StatelessWidget {
  const UserVffIncomingRequestListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: AppDimens.v24),
        children: [
          _vffFullListSectionTitleShimmer(),
          for (var i = 0; i < 4; i++) ...[
            _inboxRequestCardShimmer(),
            if (i < 3) SizedBox(height: AppDimens.v16),
          ],
        ],
      ),
    );
  }
}

/// [UserVffGroupInvitationsScreen] — matches loaded list (title + 16px card gaps).
final class UserVffGroupInvitationListShimmer extends StatelessWidget {
  const UserVffGroupInvitationListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: AppDimens.v24),
        children: [
          _vffFullListSectionTitleShimmer(),
          for (var i = 0; i < 4; i++) ...[
            _vffGroupInvitationCardShimmer(),
            if (i < 3) SizedBox(height: AppDimens.v16),
          ],
        ],
      ),
    );
  }
}

BoxDecoration _vffInboxListCardDecoration() => BoxDecoration(
      color: AppColors.vffInboxRequestCardBg,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColors.vffInboxRequestCardBorder, width: 1),
    );

Widget _vffGroupInvitationCardShimmer() {
  return Container(
    padding: EdgeInsets.all(AppDimens.p16),
    decoration: _vffInboxListCardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer.box(width: 160.w, height: 16.h, borderRadius: 4.r),
        SizedBox(height: 3.h),
        AppShimmer.box(width: 120.w, height: 12.h, borderRadius: 4.r),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: AppShimmer.box(
                width: double.infinity,
                height: 40.h,
                borderRadius: 10.r,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AppShimmer.box(
                width: double.infinity,
                height: 40.h,
                borderRadius: 10.r,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _groupInviteCardShimmer() {
  return Container(
    padding: EdgeInsets.all(AppDimens.p16),
    decoration: _vffInboxListCardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer.box(width: 160.w, height: 16.h, borderRadius: 4.r),
        SizedBox(height: 3.h),
        AppShimmer.box(width: 120.w, height: 12.h, borderRadius: 4.r),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: AppShimmer.box(
                width: double.infinity,
                height: 40.h,
                borderRadius: 10.r,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AppShimmer.box(
                width: double.infinity,
                height: 40.h,
                borderRadius: 10.r,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// VFF peer profile skeleton (connected Figma layout or public sheet).
class UserVffProfileShimmer extends StatelessWidget {
  final bool connectedLayout;

  const UserVffProfileShimmer({
    super.key,
    this.connectedLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final hero = Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.p18,
        AppDimens.v8,
        AppDimens.p18,
        8.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: AppShimmer.box(width: 100.r, height: 100.r, borderRadius: 50.r),
          ),
          SizedBox(height: 10.h),
          Center(
            child: AppShimmer.box(width: 88.w, height: 22.h, borderRadius: 11.r),
          ),
          SizedBox(height: 10.h),
          Center(
            child: AppShimmer.box(width: 160.w, height: 22.h, borderRadius: 4.r),
          ),
          SizedBox(height: 6.h),
          Center(
            child: AppShimmer.box(width: 100.w, height: 14.h, borderRadius: 4.r),
          ),
        ],
      ),
    );

    final body = Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.p18,
        connectedLayout ? 12.h : AppDimens.p18,
        AppDimens.p18,
        AppDimens.v92,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!connectedLayout) ...[
            Row(
              children: [
                AppShimmer.box(width: 100.r, height: 100.r, borderRadius: 50.r),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer.box(width: 72.w, height: 20.h, borderRadius: 10.r),
                      SizedBox(height: 8.h),
                      AppShimmer.box(width: 140.w, height: 20.h, borderRadius: 4.r),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
          ],
          Row(
            children: [
              Expanded(child: _metricBlock()),
              SizedBox(width: 10.w),
              Expanded(child: _metricBlock()),
            ],
          ),
          SizedBox(height: 20.h),
          AppShimmer.box(width: 140.w, height: 18.h, borderRadius: 4.r),
          SizedBox(height: 12.h),
          for (var i = 0; i < 3; i++) ...[
            AppShimmer.box(
              width: double.infinity,
              height: 64.h,
              borderRadius: 12.r,
            ),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: connectedLayout
            ? Column(
                children: [
                  hero,
                  body,
                ],
              )
            : body,
      ),
    );
  }

  Widget _metricBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer.box(width: 56.w, height: 11.h, borderRadius: 4.r),
        SizedBox(height: 6.h),
        AppShimmer.box(width: 48.w, height: 20.h, borderRadius: 4.r),
      ],
    );
  }
}

/// Invite-members VFF picker grid skeleton.
class UserVffInviteGridShimmer extends StatelessWidget {
  const UserVffInviteGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 34.w,
          mainAxisExtent: 88.h,
        ),
        itemCount: 8,
        itemBuilder: (context, index) => Column(
          children: [
            AppShimmer.box(width: 60.r, height: 60.r, borderRadius: 30.r),
            SizedBox(height: 4.h),
            AppShimmer.box(width: 48.w, height: 12.h, borderRadius: 4.r),
          ],
        ),
      ),
    );
  }
}
