import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../cubit/create_project_cubit.dart';
import '../../domain/create_project_form.dart';
import 'form_helpers.dart';

/// Final screen – project created successfully.
class ProjectSuccessScreen extends StatelessWidget {
  const ProjectSuccessScreen({super.key});

  String _buildShareLink(CreateProjectForm form) {
    final slug = form.projectName.trim().toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(' ', '-');
    return '${AppStrings.shareBaseDomain}/$slug-${DateTime.now().year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final shareLink = _buildShareLink(form);
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.appBackgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Success illustration ───────────────────────
                    SvgPicture.asset(
                      AppAssets.projectCreatedImage,
                      width: 120.w,
                      height: 120.w,
                    ),
                    SizedBox(height: 24.h),

                    // ── Title ─────────────────────────────────────
                    Text(
                      AppStrings.projectCreatedTitle,
                      style: GoogleFonts.lato(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Share link box ────────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              shareLink,
                              style: GoogleFonts.lato(
                                fontSize: 13.sp,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: shareLink));
                              AppSnackBar.showSuccess(
                                  context, AppStrings.linkCopied);
                            },
                            child: Icon(Icons.copy_outlined,
                                size: 20.w, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── Share via WhatsApp ─────────────────────────
                    GestureDetector(
                      onTap: () async {
                        final msg = '${AppStrings.shareWhatsappPrefix}$shareLink';
                        final uri = Uri.parse(
                            'https://wa.me/?text=${Uri.encodeComponent(msg)}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Text(
                        AppStrings.shareViaWhatsapp,
                        style: GoogleFonts.lato(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // // ── Go to my Project ──────────────────────────
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 50.h,
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       // Reset wizard state before navigating so a fresh
                    //       // session starts if the user creates another project.
                    //       context.read<CreateProjectCubit>().reset();
                    //       context.go(AppRoutes.dashboard);
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: AppColors.cardActionBtn,
                    //       foregroundColor: Colors.white,
                    //       elevation: 0,
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(100.r)),
                    //     ),
                    //     child: Text(
                    //       AppStrings.btnGoToMyProject,
                    //       style: GoogleFonts.lato(
                    //           fontSize: 15.sp,
                    //           fontWeight: FontWeight.w600),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 32.h),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 20.h),
                        child: CPNextButton(
                          label:    AppStrings.btnGoToMyProject,
                          onPressed: () {
                            // Reset wizard state before navigating so a fresh
                            // session starts if the user creates another project.
                            context.read<CreateProjectCubit>().reset();
                            context.go(AppRoutes.dashboard);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
