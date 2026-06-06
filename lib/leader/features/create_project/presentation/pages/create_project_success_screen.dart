import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vestie/core/utils/whatsapp_launch.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/core/utils/invite_share_link_resolver.dart';
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

  /// From API project type — used when opening detail (form may reset before tap).
  final bool isInvestment;

  const CreateProjectSuccessScreen({
    super.key,
    required this.projectId,
    this.projectName,
    this.isInvestment = false,
  });

  @override
  State<CreateProjectSuccessScreen> createState() =>
      _CreateProjectSuccessScreenState();
}

class _CreateProjectSuccessScreenState
    extends State<CreateProjectSuccessScreen> {
  bool _loadingInvite = true;
  String? _shareText;

  static String _inviteUrlFromApi(String apiValue) =>
      resolveInviteShareLink(apiValue);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInvite());
  }

  Future<void> _fetchInvite() async {
    if (!mounted) return;

    if (widget.projectId.isEmpty) {
      setState(() {
        _loadingInvite = false;
        _shareText = '';
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
          _shareText = '';
        });
      },
      (inviteCode) {
        setState(() {
          _loadingInvite = false;
          _shareText = _inviteUrlFromApi(inviteCode);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final shareLink = _shareText ?? '';
        final canShare = shareLink.isNotEmpty && !_loadingInvite;

        return AppSuccessScreen(
          title: AppStrings.projectCreatedTitle,
          buttonText: AppStrings.btnGoToMyProject,
          onButtonPressed: () {
            final apiName = widget.projectName?.trim() ?? '';
            final formName = form.projectName.trim();
            final detailName = apiName.isNotEmpty ? apiName : formName;
            final isInvestment =
                widget.isInvestment ||
                form.category == NewProjectCategory.investment;
            context.read<CreateProjectCubit>().reset();
            openProjectDetailAfterCreateSuccess(
              context,
              projectId: widget.projectId,
              isInvestment: isInvestment,
              projectName: detailName.isEmpty ? null : detailName,
            );
          },
          customContent: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                              style: Theme.of(context).textTheme.bodyLarge
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
                                      ClipboardData(text: shareLink),
                                    );
                                    AppSnackBar.showSuccess(
                                      context,
                                      AppStrings.linkCopied,
                                    );
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
