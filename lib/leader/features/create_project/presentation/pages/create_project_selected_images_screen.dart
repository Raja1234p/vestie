import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_image_limits.dart';
import 'package:vestie/leader/features/create_project/presentation/cubit/create_project_cubit.dart';
import 'package:vestie/leader/features/create_project/presentation/utils/create_project_image_picker.dart';
import 'package:vestie/leader/features/create_project/presentation/widgets/create_project_header.dart';
import 'package:vestie/leader/features/create_project/presentation/widgets/create_project_selected_images_grid.dart';

/// Grid of selected project images — before review (max 5).
class CreateProjectSelectedImagesScreen extends StatelessWidget {
  const CreateProjectSelectedImagesScreen({super.key});

  void _backToUploadImages(BuildContext context) {
    context.read<CreateProjectCubit>().clearProjectImages();
    if (context.mounted) context.pop();
  }

  void _pickMore(BuildContext context, CreateProjectForm form) {
    if (!form.canAddMoreProjectImages) return;

    CreateProjectImagePicker.showSourceSheet(
      context,
      remainingSlots: form.remainingProjectImageSlots,
      onPicked: (paths) =>
          context.read<CreateProjectCubit>().addProjectImages(paths),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final images = form.projectImagePaths;
        final badge = AppStrings.createProjectImagesCountBadge(
          images.length,
          CreateProjectImageLimits.maxImages,
        );

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _backToUploadImages(context);
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: PostAuthGradientBackground(
              child: Column(
                children: [
                  CreateProjectHeader(
                    title: AppStrings.createProjectSelectedImagesTitle,
                    stepBadge: badge,
                    onBack: () => _backToUploadImages(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppDimens.postAuthFlowScrollPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            AppStrings.createProjectAddedImagesLabel,
                            style: GoogleFonts.lato(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.authLabel,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          CreateProjectSelectedImagesGrid(
                            imagePaths: images,
                            onRemoveAt: (index) => context
                                .read<CreateProjectCubit>()
                                .removeProjectImageAt(index),
                            onUploadTap: () => _pickMore(context, form),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FlowScreenFooter(
                    child: AppButton(
                      text: AppStrings.btnNext,
                      useGradient: false,
                      hasShadow: false,
                      color: AppColors.neutral1200,
                      borderRadius: 10.r,
                      onPressed: () =>
                          context.push(AppRoutes.createProjectReview),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
