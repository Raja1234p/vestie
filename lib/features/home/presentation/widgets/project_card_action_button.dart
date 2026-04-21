import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/project.dart';

class ProjectActionButton extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectActionButton({
    super.key,
    required this.project,
    required this.onTap,
  });

  String get _label {
    if (project.relation == ProjectRelation.owned) return AppStrings.btnView;
    if (project.requestPending) return AppStrings.btnSendRequest;
    return AppStrings.btnJoin;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardActionBtn,
          foregroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          _label,
          style: GoogleFonts.lato(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
