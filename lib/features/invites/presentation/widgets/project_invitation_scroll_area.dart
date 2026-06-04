import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_text.dart';

import '../cubit/project_invitation_cubit.dart';
import '../cubit/project_invitation_state.dart';
import 'project_invitation_body.dart';
import 'project_invitation_shimmer.dart';

/// Scrollable invite content — layout mirrors [AppSuccessScreen] `_SuccessScrollBody`.
class ProjectInvitationScrollArea extends StatelessWidget {
  const ProjectInvitationScrollArea({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectInvitationCubit, ProjectInvitationState>(
      builder: (context, state) {
        final Widget child;
        if (state.loading) {
          child = const ProjectInvitationBodyShimmer();
        } else if (state.errorMessage != null) {
          child = Center(
            child: AppText(
              state.errorMessage!,
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          );
        } else if (state.preview case final preview?) {
          child = ProjectInvitationBody(preview: preview);
        } else {
          child = const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 16.h),
            child: child,
          ),
        );
      },
    );
  }
}
