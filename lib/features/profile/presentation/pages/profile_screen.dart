import 'dart:io';
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
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import '../../../../core/widgets/common/app_text.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/app_shimmer.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/settings_section.dart';

class ProfileScreen extends StatefulWidget {
  final bool activate;

  const ProfileScreen({super.key, required this.activate});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileCubit _cubit = ProfileCubit();

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
        listener: (context, state) {
          if (state.isLogoutSuccess) {
            context.go(AppRoutes.login);
          }
        },
        child: const _ProfileBody(),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  Widget _buildPickerAction({
    required BuildContext context,
    required String glyphAsset,
    required String title,
    required ImageSource source,
  }) {
    return ListTile(
      leading: AppSvgIcon(
          assetPath: glyphAsset, size: 24.w, color: AppColors.textPrimary),
      title: AppText(title),
      onTap: () {
        context.pop();
        context.read<ProfileCubit>().pickAvatar(source);
      },
    );
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPickerAction(
              context: context,
              glyphAsset: AppAssets.iconCamera,
              title: AppStrings.takePhoto,
              source: ImageSource.camera,
            ),
            _buildPickerAction(
              context: context,
              glyphAsset: AppAssets.iconPhotoLibrary,
              title: AppStrings.chooseFromGallery,
              source: ImageSource.gallery,
            ),
          ],
        ),
      ),
    );
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
                    padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      state.isLoading && profile.fullName.isEmpty
                          ? const ProfileHeaderShimmer()
                          : Row(children: [
                              GestureDetector(
                                onTap: () => _showAvatarPicker(context),
                                child: Stack(children: [
                                  CircleAvatar(
                                    radius: 50.r,
                                    backgroundColor: AppColors.cardBorder,
                                    backgroundImage: state.avatarFile != null
                                        ? FileImage(state.avatarFile as File)
                                        : null,
                                    child: state.avatarFile == null
                                        ? AppSvgIcon(
                                            assetPath: AppAssets.iconPerson,
                                            size: 30.w,
                                            color: AppColors.textBody,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: SvgPicture.asset(
                                      AppAssets.profileAvatarEditBadge,
                                      width: 22.w,
                                      height: 22.w,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ]),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    profile.fullName.isNotEmpty
                                        ? profile.fullName
                                        : AppStrings.appName, // Fallback to app name or "User"
                                    style: GoogleFonts.lato(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF141414),
                                    ),
                                  ),
                                  AppText(
                                    profile.email.isNotEmpty
                                        ? profile.email
                                        : '...', // Fallback or loading indicator
                                    style: GoogleFonts.lato(
                                      fontSize: 13.sp,
                                      color: AppColors.textBody,
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      SizedBox(height: 18.h),
                      AppText(
                        AppStrings.settingsLabel,
                        style: GoogleFonts.lato(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF141414),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SettingsSection(items: [
                        SettingsItem(
                          assetPath: AppAssets.iconPerson,
                          label: AppStrings.menuEditProfile,
                          onTap: () async {
                            await context.push(AppRoutes.editProfile);
                            if (!context.mounted) return;
                            await context.read<ProfileCubit>().refreshProfile();
                          },
                        ),
                        SettingsItem(
                          assetPath: AppAssets.iconPaymentMethods,
                          label: AppStrings.menuPaymentMethods,
                          onTap: () => context.push(AppRoutes.paymentMethods),
                        ),
                        SettingsItem(
                          assetPath: AppAssets.iconDollarCircle,
                          label: AppStrings.menuTransactionHistory,
                          onTap: () => context.push(AppRoutes.transactionHistory),
                        ),
                        SettingsItem(
                          assetPath: AppAssets.iconKeyGuidelines,
                          label: AppStrings.menuKeyGuidelines,
                          onTap: () => context.push(AppRoutes.keyGuidelines),
                        ),
                      ]),
                      const Spacer(),
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
    );
  }
}
