import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';

/// Announcement block on project detail — card + optional delete control (Figma).
///
/// Delete is shown only when [canDeleteAnnouncement] is true (GroupLeader / CoLeader).
class AnnouncementCard extends StatelessWidget {
  final String? text;
  final bool canDeleteAnnouncement;
  final VoidCallback? onDelete;

  const AnnouncementCard({
    super.key,
    this.text,
    this.canDeleteAnnouncement = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final showDelete = canDeleteAnnouncement && onDelete != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _AnnouncementBody(text: text)),
          if (showDelete) ...[
            SizedBox(width: 8.w),
            _AnnouncementDeleteButton(onTap: onDelete!),
          ],
        ],
      ),
    );
  }
}

class _AnnouncementBody extends StatelessWidget {
  final String? text;

  const _AnnouncementBody({this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.purple300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.announcementTitle,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.projectDetailText,
            ),
          ),
          SizedBox(height: 4.h),
          AppText(
            text ?? AppStrings.announcementPlaceholder,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey800,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementDeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AnnouncementDeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.red100,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 48.w,
          child: Center(
            child: SvgPicture.asset(
              AppAssets.iconDelete,
              width: 22.w,
              height: 22.w,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                AppColors.red900,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
