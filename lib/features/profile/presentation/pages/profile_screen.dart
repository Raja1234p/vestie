import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_text.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/settings_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  Widget _buildPickerAction({
    required BuildContext context,
    required IconData icon,
    required String title,
    required ImageSource source,
  }) {
    return ListTile(
      leading: Icon(icon),
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
              icon: Icons.camera_alt_outlined,
              title: AppStrings.takePhoto,
              source: ImageSource.camera,
            ),
            _buildPickerAction(
              context: context,
              icon: Icons.photo_library_outlined,
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
                _ProfileHeader(
                  onSettings: () => context.push(AppRoutes.editProfile),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Row(children: [
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
                                  ? Icon(
                                      Icons.person,
                                      size: 30.w,
                                      color: AppColors.textBody,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 22.w,
                                height: 22.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 15.w,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              profile.fullName,
                              style: GoogleFonts.lato(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            AppText(
                              profile.username,
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
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SettingsSection(items: [
                        SettingsItem(
                          svgPath: AppAssets.iconEditProfile,
                          label: AppStrings.menuEditProfile,
                          onTap: () => context.push(AppRoutes.editProfile),
                        ),
                        SettingsItem(
                          svgPath: AppAssets.iconPaymentMethods,
                          label: AppStrings.menuPaymentMethods,
                          onTap: () => context.push(AppRoutes.paymentMethods),
                        ),
                        SettingsItem(
                          svgPath: AppAssets.iconTransactionHistory,
                          label: AppStrings.menuTransactionHistory,
                          onTap: () => context.push(AppRoutes.transactionHistory),
                        ),
                        SettingsItem(
                          svgPath: AppAssets.iconKeyGuidelines,
                          label: AppStrings.menuKeyGuidelines,
                          onTap: () => context.push(AppRoutes.keyGuidelines),
                        ),
                      ]),
                      const Spacer(),
                      ProfileLogoutButton(
                        onTap: () => context.go(AppRoutes.login),
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
  final VoidCallback onSettings;
  const _ProfileHeader({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 16.h),

      child: Row(
        children: [
          AppText(AppStrings.profileTitle,
              style: GoogleFonts.lato(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
          const Spacer(),
          GestureDetector(
            onTap: onSettings,
            child: Icon(Icons.settings_outlined,
                size: 22.w, color: AppColors.textBody),
          ),
        ],
      ),
    );
  }
}
