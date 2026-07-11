import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_permission_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_toast.dart';
import '../../../../core/widgets/common/app_loading_dialog.dart';
import '../../../../core/widgets/common/app_network_avatar.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import '../../../../core/widgets/common/app_text.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/app_shimmer.dart';
import '../cubit/profile_cubit.dart';
import '../navigation/delete_account_flow.dart';
import '../widgets/profile_header_more_options_action.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_photo_dialog.dart';
import '../widgets/settings_section.dart';

class ProfileScreen extends StatefulWidget {
  final bool activate;

  const ProfileScreen({super.key, required this.activate});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileCubit _cubit = ProfileCubit();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.activate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cubit.ensureTabVisible();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activate && !oldWidget.activate) {
      _cubit.ensureTabVisible();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.activate) {
      return const SizedBox.shrink();
    }
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (prev, curr) =>
            curr.isLogoutSuccess && !prev.isLogoutSuccess,
        listener: (context, state) {
          if (state.isLogoutSuccess) {
            context.go(AppRoutes.login);
          }
        },
        child: _ProfileBody(imagePicker: _imagePicker),
      ),
    );
  }
}

String _profileInitials(String name) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
  return t.substring(0, 1).toUpperCase();
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.imagePicker});

  final ImagePicker imagePicker;

  Future<void> _runPhotoTask(
    BuildContext context, {
    required Future<String?> Function() task,
    required String loadingMessage,
  }) async {
    if (!context.mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => AppLoadingDialog.body(message: loadingMessage),
    );

    String? error;
    try {
      error = await task();
    } finally {
      if (context.mounted) {
        navigator.pop();
      }
    }

    if (error != null && context.mounted) {
      AppToast.showError(context, error);
    }
  }

  Future<void> _pickAndUpload(BuildContext context, ImageSource source) async {
    final allowed = await AppPermissionHelper.ensureImageSource(
      context,
      source,
    );
    if (!allowed) return;

    final picked = await imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 400,
      requestFullMetadata: AppPermissionHelper.galleryPickRequestsFullMetadata(
        source,
      ),
    );
    if (picked == null || !context.mounted) return;

    await _runPhotoTask(
      context,
      loadingMessage: AppStrings.profilePhotoUploading,
      task: () => context.read<ProfileCubit>().uploadPhotoFile(picked.path),
    );
  }

  Future<void> _showPhotoDialog(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final profile = cubit.state.profile;
    await ProfilePhotoDialog.show(
      context,
      photoUrl: profile.photoUrl,
      initials: _profileInitials(profile.fullName),
      onChangeImage: () => _showAvatarPicker(context),
      onRemoveImage: () => _runPhotoTask(
        context,
        loadingMessage: AppStrings.profilePhotoRemoving,
        task: cubit.removeAvatar,
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PickerTile(
              glyphAsset: AppAssets.profileCamera,
              title: AppStrings.takePhoto,
              onTap: () {
                Navigator.pop(sheetContext);
                AppPermissionHelper.runAfterModalClosed(
                  context,
                  () => _pickAndUpload(context, ImageSource.camera),
                );
              },
            ),
            _PickerTile(
              glyphAsset: AppAssets.profilePhotoLibrary,
              title: AppStrings.chooseFromGallery,
              onTap: () {
                Navigator.pop(sheetContext);
                AppPermissionHelper.runAfterModalClosed(
                  context,
                  () => _pickAndUpload(context, ImageSource.gallery),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onAvatarTap(BuildContext context) {
    final state = context.read<ProfileCubit>().state;
    if (state.hasProfilePhoto) {
      _showPhotoDialog(context);
    } else {
      _showAvatarPicker(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ProfileHeader(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                state.isLoading && profile.fullName.isEmpty
                                    ? const ProfileHeaderShimmer()
                                    : Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => _onAvatarTap(context),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                AppNetworkAvatar(
                                                  imageUrl: profile.photoUrl,
                                                  initials: _profileInitials(
                                                    profile.fullName,
                                                  ),
                                                  size: 54.w,
                                                  backgroundColor:
                                                      AppColors.cardBorder,
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: SvgPicture.asset(
                                                    AppAssets
                                                        .profileAvatarEditBadge,
                                                    width:  20.w,
                                                    height:  20.w,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AppText(
                                                profile.fullName.isNotEmpty
                                                    ? profile.fullName
                                                    : AppStrings.appName,
                                                style: GoogleFonts.lato(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(
                                                    0xFF141414,
                                                  ),
                                                ),
                                              ),
                                              if (profile.username.isNotEmpty)
                                                AppText(
                                                  profile.username,
                                                  style: GoogleFonts.lato(
                                                    fontSize: 13.sp,
                                                    color: AppColors.textBody,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                SizedBox(height: 10.h),
                                AppText(
                                  AppStrings.settingsLabel,
                                  style: GoogleFonts.lato(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF141414),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                SettingsSection(
                                  items: [
                                    SettingsItem(
                                      assetPath: AppAssets.iconPerson,
                                      label: AppStrings.menuEditProfile,
                                      onTap: () async {
                                        await context.push(
                                          AppRoutes.editProfile,
                                        );
                                        if (!context.mounted) return;
                                        await context
                                            .read<ProfileCubit>()
                                            .refreshProfile();
                                      },
                                    ),
                                    SettingsItem(
                                      assetPath:
                                          AppAssets.profilePaymentMethods,
                                      label: AppStrings.menuPaymentMethods,
                                      onTap: () => context.push(
                                        AppRoutes.paymentMethods,
                                      ),
                                    ),
                                    SettingsItem(
                                      assetPath: AppAssets.iconDollarCircle,
                                      label: AppStrings.menuMyAccounts,
                                      onTap: () =>
                                          context.push(AppRoutes.myAccounts),
                                    ),
                                    SettingsItem(
                                      assetPath:
                                          AppAssets.profileCompletedProjects,
                                      label: AppStrings.menuCompletedProjects,
                                      onTap: () => context.push(
                                        AppRoutes.completedProjects,
                                      ),
                                    ),
                                    SettingsItem(
                                      assetPath: AppAssets.iconDollarCircle,
                                      label: AppStrings.menuTransactionHistory,
                                      onTap: () => context.push(
                                        AppRoutes.transactionHistory,
                                      ),
                                    ),
                                    SettingsItem(
                                      assetPath: AppAssets.profileGuidelines,
                                      label: AppStrings.menuKeyGuidelines,
                                      onTap: () =>
                                          context.push(AppRoutes.keyGuidelines),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        ProfileLogoutButton(
                          isLoading: state.isLoggingOut,
                          onTap: () => context.read<ProfileCubit>().logout(),
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.glyphAsset,
    required this.title,
    required this.onTap,
  });

  final String glyphAsset;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AppSvgIcon(
        assetPath: glyphAsset,
        size: 24.w,
        color: AppColors.textPrimary,
      ),
      title: AppText(title),
      onTap: onTap,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return PostAuthHeader(
      title: AppStrings.profileTitle,
      titleStyle: GoogleFonts.lato(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF141414),
        letterSpacing: -0.5,
      ),
      trailing: ProfileHeaderMoreOptionsAction(
        onSelected: (action) {
          if (action != ProfileHeaderMenuAction.deleteAccount) return;
          // Defer until the popup route finishes closing — avoids first tap being swallowed.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            openDeleteAccountFlow(context, context.read<ProfileCubit>());
          });
        },
      ),
    );
  }
}
