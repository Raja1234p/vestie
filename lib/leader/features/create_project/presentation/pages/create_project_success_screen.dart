import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vestie/core/utils/whatsapp_launch.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../domain/create_project_form.dart';
import '../cubit/create_project_cubit.dart';

/// Success step — fetches invite via `POST /projects/{id}/invites`, then copy / WhatsApp.
class CreateProjectSuccessScreen extends StatefulWidget {
  final String projectId;

  /// From `POST /projects` response — used for detail header if form is reset.
  final String? projectName;

  const CreateProjectSuccessScreen({
    super.key,
    required this.projectId,
    this.projectName,
  });

  @override
  State<CreateProjectSuccessScreen> createState() =>
      _CreateProjectSuccessScreenState();
}

class _CreateProjectSuccessScreenState extends State<CreateProjectSuccessScreen> {
  bool _loadingInvite = true;
  String? _shareText;

  static String _fallbackShareLink(CreateProjectForm form) {
    final slug = form.projectName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(' ', '-');
    return 'https://${AppStrings.shareBaseDomain}/$slug-${DateTime.now().year}';
  }

  static String _inviteUrlFromCode(String code) =>
      'https://${AppStrings.shareBaseDomain}/$code';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInvite());
  }

  Future<void> _fetchInvite() async {
    if (!mounted) return;

    if (widget.projectId.isEmpty) {
      final form = context.read<CreateProjectCubit>().state;
      setState(() {
        _loadingInvite = false;
        _shareText = _fallbackShareLink(form);
      });
      return;
    }

    final form = context.read<CreateProjectCubit>().state;
    final result = await ServiceLocator.instance.createInviteUseCase(
      projectId: widget.projectId,
      requiresApproval: form.visibility != ProjectVisibility.public,
      expiresInDays: 30,
      maxUses: 25,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        AppSnackBar.showError(context, failure.message);
        setState(() {
          _loadingInvite = false;
          _shareText = _fallbackShareLink(form);
        });
      },
      (inviteCode) {
        final trimmed = inviteCode.trim();
        setState(() {
          _loadingInvite = false;
          _shareText = trimmed.isEmpty
              ? _fallbackShareLink(form)
              : _inviteUrlFromCode(trimmed);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final shareLink =
            _shareText ?? (_loadingInvite ? '' : _fallbackShareLink(form));
        final canShare = shareLink.isNotEmpty && !_loadingInvite;

        return AppSuccessScreen(
          svgAssetPath: AppAssets.projectCreatedImage,
          title: AppStrings.projectCreatedTitle,
          buttonText: AppStrings.btnGoToMyProject,
          onButtonPressed: () {
            final category = form.category;
            final apiName = widget.projectName?.trim() ?? '';
            final formName = form.projectName.trim();
            final detailName =
                apiName.isNotEmpty ? apiName : formName;
            context.read<CreateProjectCubit>().reset();
            openProjectDetailAfterCreateSuccess(
              context,
              projectId: widget.projectId,
              category: category,
              projectName: detailName.isEmpty ? null : detailName,
            );
          },
          customContent: Column(
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.purple300.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: _loadingInvite
                    ? SizedBox(
                        height: 24.h,
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: AppText(
                              shareLink,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontSize: 15.sp,
                                    color: Colors.black,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: canShare
                                ? () {
                                    Clipboard.setData(
                                        ClipboardData(text: shareLink));
                                    AppSnackBar.showSuccess(
                                        context, AppStrings.linkCopied);
                                  }
                                : null,
                            child: AppSvgIcon(
                              assetPath: AppAssets.iconCopy,
                              size: 20.w,
                              color: canShare
                                  ? AppColors.primary
                                  : AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          bottomContent: GestureDetector(
            onTap: canShare
                ? () async {
                    final ctx = context;
                    final msg = AppStrings.shareWhatsappMessage(shareLink);
                    final ok = await launchWhatsAppShareText(msg);
                    if (!ctx.mounted || ok) return;
                    AppSnackBar.showError(ctx, AppStrings.errorGeneric);
                  }
                : null,
            child: AppText(
              AppStrings.shareViaWhatsapp,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: canShare ? Colors.black : AppColors.grey500,
                  ),
            ),
          ),
        );
      },
    );
  }
}
