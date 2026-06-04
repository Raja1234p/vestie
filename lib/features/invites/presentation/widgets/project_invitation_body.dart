import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/roi_display_format.dart';
import 'package:vestie/core/widgets/common/app_text.dart';
import 'package:vestie/features/projects/domain/entities/invite_preview_entity.dart';

import 'project_invitation_description_section.dart';
import 'project_invitation_expected_roi_card.dart';
import 'project_invitation_hero.dart';
import 'project_invitation_stats_row.dart';

class ProjectInvitationBody extends StatelessWidget {
  final InvitePreviewEntity preview;

  const ProjectInvitationBody({super.key, required this.preview});

  @override
  Widget build(BuildContext context) {
    final showRoiCard = preview.isInvestment &&
        isDisplayableRoi(preview.roiPercentage);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          SizedBox(height: 58.h),
          const ProjectInvitationHero(),
          SizedBox(height: AppDimens.v16),
          AppText(
            preview.projectName,
            style: GoogleFonts.lato(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral1200,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          if (showRoiCard) ...[
            SizedBox(height: 16.h),
            ProjectInvitationExpectedRoiCard(
              roiPercentage: preview.roiPercentage!,
            ),
          ],
          SizedBox(height: 16.h),
          ProjectInvitationStatsRow(preview: preview),
          SizedBox(height: 16.h),
          if (preview.description != null)
            ProjectInvitationDescriptionSection(
              description: preview.description!,
            ),
          if (preview.isExpired)
            Padding(
              padding: EdgeInsets.only(top: AppDimens.v16),
              child: AppText(
                AppStrings.projectInvitationExpired,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  color: AppColors.red700,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else if (!preview.isJoinable)
            Padding(
              padding: EdgeInsets.only(top: AppDimens.v16),
              child: AppText(
                AppStrings.projectInvitationNotJoinable,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  color: AppColors.red700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: AppDimens.v24),
        ],
    );
  }
}
