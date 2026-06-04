import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/project_invite_navigation.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_text.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';

import '../../domain/invite_preview_extensions.dart';
import '../cubit/project_invitation_cubit.dart';
import '../cubit/project_invitation_state.dart';
import 'project_invitation_shimmer.dart';

/// Pinned bottom actions — [FlowScreenFooter] matches wallet / contribute flows.
class ProjectInvitationFooter extends StatelessWidget {
  const ProjectInvitationFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectInvitationCubit, ProjectInvitationState>(
      builder: (context, state) {
        if (state.loading) {
          return const FlowScreenFooter(
            child: ProjectInvitationFooterShimmerContent(),
          );
        }

        final cubit = context.read<ProjectInvitationCubit>();
        final preview = state.preview;
        final showPrimary = preview != null && state.errorMessage == null;
        final useRequestCta = preview != null &&
            (preview.isPrivateInvite || preview.requiresApproval);
        final primaryLabel = useRequestCta
            ? AppStrings.projectInvitationRequestToJoin
            : AppStrings.projectInvitationJoinProject;

        return FlowScreenFooter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showPrimary) ...[
                AppButton(
                  text: primaryLabel,
                  onPressed: state.canJoin ? cubit.join : null,
                  isLoading: state.joining,
                ),
                SizedBox(height: 16.h),
              ],
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ProjectInviteNavigation.goMaybeLater(context),
                  borderRadius: BorderRadius.circular(8.r),
                  splashColor:
                      AppColors.guidelineTitle.withValues(alpha: 0.12),
                  highlightColor:
                      AppColors.guidelineTitle.withValues(alpha: 0.06),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Center(
                      child: AppText(
                        AppStrings.projectInvitationMaybeLater,
                        style: GoogleFonts.lato(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.guidelineTitle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
