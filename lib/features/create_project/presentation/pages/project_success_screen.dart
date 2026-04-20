import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/create_project_form.dart';
import '../cubit/create_project_cubit.dart';
import '../../../../core/widgets/common/app_success_screen.dart';

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
        return AppSuccessScreen(
          svgAssetPath: AppAssets.projectCreatedImage,
          title: AppStrings.projectCreatedTitle,
          buttonText: AppStrings.btnGoToMyProject,
          onButtonPressed: () {
            context.read<CreateProjectCubit>().reset();
            context.go(AppRoutes.dashboard);
          },
          customContent: Column(
            children: [
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
                      child: AppText(
                        shareLink,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

              SizedBox(height: 32.h), // ── Share via WhatsApp ─────────────────────────
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
                child: AppText(
                  AppStrings.shareViaWhatsapp,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
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
