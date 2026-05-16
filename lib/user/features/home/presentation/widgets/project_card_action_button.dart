import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import '../../domain/entities/project.dart';

class ProjectActionButton extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final bool discoverCtaStyle;

  const ProjectActionButton({
    super.key,
    required this.project,
    required this.onTap,
    this.discoverCtaStyle = false,
  });

  String get _label {
    if (project.status == ProjectStatus.completed) {
      return AppStrings.btnView;
    }
    if (project.relation == ProjectRelation.owned) return AppStrings.btnView;
    if (!discoverCtaStyle && project.relation == ProjectRelation.joined) {
      return AppStrings.btnView;
    }
    if (project.requestPending) return AppStrings.btnSendRequest;
    if (discoverCtaStyle) {
      return project.isPublic
          ? AppStrings.btnJoin
          : AppStrings.btnRequestToJoin;
    }
    return AppStrings.btnJoin;
  }

  TextStyle get _textStyle {
    if (discoverCtaStyle &&
        project.status == ProjectStatus.ongoing &&
        project.relation != ProjectRelation.owned &&
        !project.requestPending) {
      return GoogleFonts.lato(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.surface,
      );
    }
    return GoogleFonts.lato(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.surface,
    );
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
        child: Text(_label, style: _textStyle),
      ),
    );
  }
}
