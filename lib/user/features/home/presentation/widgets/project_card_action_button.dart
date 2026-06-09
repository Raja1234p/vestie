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
  final bool isLoading;

  const ProjectActionButton({
    super.key,
    required this.project,
    required this.onTap,
    this.discoverCtaStyle = false,
    this.isLoading = false,
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
    if (project.status == ProjectStatus.completed) {
      return GoogleFonts.lato(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF000000),
      );
    }
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
    final isCompletedViewStyle = project.status == ProjectStatus.completed;
    final radius = BorderRadius.circular(10.r);

    return Material(
      color: isCompletedViewStyle
          ? Colors.transparent
          : AppColors.cardActionBtn,
      borderRadius: isCompletedViewStyle ? null : radius,
      shape: isCompletedViewStyle
          ? RoundedRectangleBorder(
              borderRadius: radius,
              side: const BorderSide(color: Color(0xFF000000), width: 1),
            )
          : null,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: radius,
        child: SizedBox(
          width: double.infinity,
          height: 44.h,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isCompletedViewStyle
                          ? const Color(0xFF000000)
                          : AppColors.surface,
                    ),
                  )
                : Text(_label, style: _textStyle),
          ),
        ),
      ),
    );
  }
}
