import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';

/// Announcement block on project detail — card + swipe-to-delete for moderators.
///
/// Delete is enabled only when [canDeleteAnnouncement] is true (GroupLeader / CoLeader).
class AnnouncementCard extends StatelessWidget {
  final String? announcementId;
  final String? heading;
  final String? text;
  final bool canDeleteAnnouncement;
  final VoidCallback? onDelete;

  const AnnouncementCard({
    super.key,
    this.announcementId,
    this.heading,
    this.text,
    this.canDeleteAnnouncement = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final body = _AnnouncementBody(heading: heading, text: text);
    final showDelete = canDeleteAnnouncement && onDelete != null;

    if (!showDelete) return body;

    return Dismissible(
      key: ValueKey<String>(
        'project-announcement-${announcementId ?? 'placeholder'}',
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete!(),
      background: const _AnnouncementSwipeDeleteBackground(),
      child: body,
    );
  }
}

class _AnnouncementBody extends StatelessWidget {
  final String? heading;
  final String? text;

  const _AnnouncementBody({this.heading, this.text});

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
          if (heading != null && heading!.trim().isNotEmpty) ...[
            AppText(
              heading!.trim(),
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.projectDetailText,
              ),
            ),
            SizedBox(height: 4.h),
          ],
          AppText(
            (text != null && text!.trim().isNotEmpty)
                ? text!.trim()
                : AppStrings.announcementPlaceholder,
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

/// Revealed on swipe — same fill + delete glyph as the legacy side button (Figma).
class _AnnouncementSwipeDeleteBackground extends StatelessWidget {
  const _AnnouncementSwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: AppColors.red100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SizedBox(
        width: 48.w,
        child: const Center(child: _AnnouncementDeleteIcon()),
      ),
    );
  }
}

class _AnnouncementDeleteIcon extends StatelessWidget {
  const _AnnouncementDeleteIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconDelete,
      width: 22.w,
      height: 22.w,
      fit: BoxFit.contain,
      colorFilter: const ColorFilter.mode(
        AppColors.red900,
        BlendMode.srcIn,
      ),
    );
  }
}
