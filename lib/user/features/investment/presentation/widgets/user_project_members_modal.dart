import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/utils/whatsapp_launch.dart';
import 'package:vestie/core/widgets/common/app_network_avatar.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

import '../models/user_investment_ui_snapshot.dart';

Future<void> showUserProjectMembersModal(
  BuildContext context, {
  required UserInvestmentUiSnapshot snapshot,
}) {
  final count = snapshot.headlineMemberCount > 0
      ? snapshot.headlineMemberCount
      : snapshot.members.length;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: const Offset(0, -6),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.grey500.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  AppText(
                    AppStrings.userInvestmentMembersModalTitle(count),
                    style: GoogleFonts.lato(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  AppText(
                    AppStrings.userInvestmentShareRowHint,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 12.sp,
                      color: AppColors.textBody,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 280.h,
                    child: GridView.builder(
                      itemCount: snapshot.members.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 8.w,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (_, i) {
                        final m = snapshot.members[i];
                        return Column(
                          children: [
                            AppNetworkAvatar(
                              imageUrl: m.photoUrl,
                              initials: m.name.isNotEmpty
                                  ? m.name[0]
                                  : '?',
                              size: 44.r,
                              backgroundColor:
                                  AppColors.purple300.withValues(alpha: 0.45),
                              textColor: AppColors.textPrimary,
                              fontSize: 14.sp,
                            ),
                            SizedBox(height: 4.h),
                            AppText(
                              m.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBody,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Divider(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ShareCircle(
                        assetPath: AppAssets.shareChat,
                        label: 'WA',
                        onTap: () async {
                          final text =
                              '${snapshot.projectName} — ${snapshot.inviteShareLink}';
                          final ok = await launchWhatsAppShareText(text);
                          if (!sheetContext.mounted || ok) return;
                          AppSnackBar.showError(
                            sheetContext,
                            AppStrings.errorGeneric,
                          );
                        },
                      ),
                      _ShareCircle(
                        assetPath: AppAssets.shareLink,
                        label: 'Copy',
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: snapshot.inviteShareLink),
                          );
                          if (context.mounted) {
                            AppSnackBar.showSuccess(
                              context,
                              AppStrings.linkCopied,
                            );
                          }
                        },
                      ),
                      _ShareCircle(
                        assetPath: AppAssets.shareFacebook,
                        label: 'FB',
                        onTap: () async {
                          final uri = Uri.parse(
                            'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(snapshot.inviteShareLink)}',
                          );
                          try {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (_) {}
                        },
                      ),
                      _ShareCircle(
                        assetPath: AppAssets.shareInstagram,
                        label: 'IG',
                        onTap: () {
                          if (context.mounted) {
                            AppSnackBar.showInfo(
                              context,
                              AppStrings.socialComingSoon,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ShareCircle extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;

  const _ShareCircle({
    required this.assetPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.searchBarBg,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: AppSvgIcon(
                assetPath: assetPath,
                size: 22.r,
                color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          AppText(
            label,
            style: GoogleFonts.lato(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
