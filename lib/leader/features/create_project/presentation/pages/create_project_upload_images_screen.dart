import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/leader/features/create_project/presentation/create_project_image_tile_style.dart';
import 'package:vestie/leader/features/create_project/presentation/widgets/create_project_header.dart';
import 'package:vestie/leader/features/create_project/presentation/widgets/create_project_upload_illustration.dart';

/// Empty-state upload step — before review in the create wizard.
class CreateProjectUploadImagesScreen extends StatelessWidget {
  const CreateProjectUploadImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            const CreateProjectHeader(
              title: AppStrings.createProjectUploadImagesTitle,
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.surface,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Center(
                                child: CreateProjectUploadIllustration(),
                              ),
                              SizedBox(
                                height: CreateProjectImageTileStyle
                                    .uploadIllustrationToTitleGap
                                    .h,
                              ),
                              AppText(
                                AppStrings.createProjectUploadImagesHeadline,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neutral1200,
                                ),
                              ),
                              SizedBox(
                                height: CreateProjectImageTileStyle
                                    .uploadTitleToSubtitleGap
                                    .h,
                              ),
                              Text.rich(
                                TextSpan(
                                  style: GoogleFonts.lato(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.grey900,
                                    height: 1.45,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: AppStrings
                                          .createProjectUploadImagesSubtitlePrefix,
                                    ),
                                    TextSpan(
                                      text: AppStrings
                                          .createProjectUploadImagesSubtitleBold,
                                      style: TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                    TextSpan(
                                      text: AppStrings
                                          .createProjectUploadImagesSubtitleSuffix,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            ColoredBox(
              color: AppColors.surface,
              child: FlowScreenFooter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: AppStrings.createProjectUploadImagesCta,
                      onPressed: () =>
                          context.push(AppRoutes.createProjectSelectedImages),
                    ),
                    SizedBox(height: 16.h),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            context.push(AppRoutes.createProjectReview),
                        borderRadius: BorderRadius.circular(8.r),
                        splashColor:
                            AppColors.grey800.withValues(alpha: 0.12),
                        highlightColor:
                            AppColors.grey800.withValues(alpha: 0.06),
                        child: Center(
                          child: AppText(
                            AppStrings.btnSkip,
                            style: GoogleFonts.lato(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
