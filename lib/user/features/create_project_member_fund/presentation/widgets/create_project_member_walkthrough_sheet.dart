import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';

void showCreateProjectMemberWalkthroughSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                AppStrings.createProjectMemberWalkthroughSheetTitle,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ListTile(
              title: Text(
                AppStrings.createProjectMemberWalkthroughVacationTitle,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                AppStrings.createProjectMemberWalkthroughVacationSubtitle,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.textBody,
                  height: 1.35,
                ),
              ),
              onTap: () {
                Navigator.of(modalContext).pop();
                context.push(AppRoutes.createProjectVacationSetup);
              },
            ),
            ListTile(
              title: Text(
                AppStrings.createProjectMemberWalkthroughEmergencyTitle,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                AppStrings.createProjectMemberWalkthroughEmergencySubtitle,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.textBody,
                  height: 1.35,
                ),
              ),
              onTap: () {
                Navigator.of(modalContext).pop();
                context.push(AppRoutes.createProjectEmergencySetup);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
