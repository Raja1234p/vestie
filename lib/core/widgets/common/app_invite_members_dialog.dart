import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../text/app_text.dart';

class AppInviteMembersDialog extends StatelessWidget {
  final String inviteLink;

  const AppInviteMembersDialog({
    super.key,
    required this.inviteLink,
  });

  static Future<void> show(
    BuildContext context, {
    String inviteLink = AppStrings.inviteLinkSample,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 14.w),
        child: AppInviteMembersDialog(inviteLink: inviteLink),
      ),
    );
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteLink));
    if (!context.mounted) return;
    AppSnackBar.showSuccess(context, AppStrings.linkCopied);
  }

  Future<void> _shareWhatsapp(BuildContext context) async {
    final msg = '${AppStrings.shareWhatsappPrefix}$inviteLink';
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(msg)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (context.mounted) {
      AppSnackBar.showError(context, AppStrings.errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(34.r),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.close_rounded,
                color: AppColors.primaryDark,
                size: 30.w,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: 312.w,
            height: 312.h,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.purple100,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Image.asset(AppAssets.inviteQrCode),
          ),
          SizedBox(height: 16.h),
          _InvitePrimaryButton(
            label: AppStrings.shareQrCode,
            onTap: () => _shareWhatsapp(context),
          ),
          SizedBox(height: 20.h),
          AppText(
            AppStrings.copyCodeFromBelow,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.grey800,
                ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.purple100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    inviteLink,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15.sp,
                          color: AppColors.grey1100,
                        ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _copyLink(context),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 22.w,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          const _DashedDivider(),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => _shareWhatsapp(context),
            child: AppText(
              AppStrings.shareViaWhatsapp,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey900,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _InvitePrimaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: AppColors.grey1200,
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.center,
        child: AppText(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.surface,
              ),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashCount = (constraints.maxWidth / 12).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dashCount,
              (_) => Container(
                width: 6.w,
                height: 1.h,
                color: AppColors.purple300,
              ),
            ),
          );
        },
      ),
    );
  }
}
