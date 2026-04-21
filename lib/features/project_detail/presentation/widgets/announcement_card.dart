import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';

/// Displays the project announcement at the top of the detail screen.
/// When [isLeader] is true a trash icon appears on the right to delete it.
class AnnouncementCard extends StatelessWidget {
  final String? text;
  final bool isLeader;
  final VoidCallback? onDelete;

  const AnnouncementCard({
    super.key,
    this.text,
    this.isLeader = false,
    this.onDelete,
  });

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Text content ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  AppStrings.announcementTitle,
                  style: GoogleFonts.lato(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey1100,
                  ),
                ),
                SizedBox(height: 4.h),
                AppText(
                  text ?? AppStrings.announcementPlaceholder,
                  style: GoogleFonts.lato(
                    fontSize: 13.sp,
                    color: AppColors.textBody,
                  ),
                ),
              ],
            ),
          ),

          // ── Delete icon (leader only) ──────────────────────────
          if (isLeader) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.red100,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  AppAssets.iconCancelProject,
                  width: 18.w,
                  height: 18.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.error,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
