import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_avatar_circle.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

class JoinRequestCard extends StatelessWidget {
  final String initials;
  final String name;
  final String username;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final bool isAcceptLoading;
  final bool isDeclineLoading;

  const JoinRequestCard({
    super.key,
    required this.initials,
    required this.name,
    required this.username,
    required this.onAccept,
    required this.onDecline,
    this.isAcceptLoading = false,
    this.isDeclineLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppAvatarCircle(initials: initials, size: 52.h),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey1100,
                        ),
                  ),
                  AppText(
                    username,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.grey800,
                        ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _ActionOutlineButton(
                  label: AppStrings.joinRequestDeclineLabel,
                  isLoading: isDeclineLoading,
                  onTap: onDecline,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ActionPrimaryButton(
                  label: AppStrings.joinRequestApproveLabel,
                  isLoading: isAcceptLoading,
                  onTap: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionOutlineButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: AppColors.grey400),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22.w,
                  height: 22.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.grey700,
                  ),
                )
              : AppText(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
                ),
        ),
      ),
    );
  }
}

class _ActionPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionPrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.grey1200,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22.w,
                  height: 22.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.surface,
                  ),
                )
              : AppText(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surface,
                      ),
                ),
        ),
      ),
    );
  }
}
