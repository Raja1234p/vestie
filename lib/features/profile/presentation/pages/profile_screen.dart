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
import '../cubit/profile_cubit.dart';
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

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text(AppStrings.takePhoto),
              onTap: () {
                Navigator.pop(context);
                context.read<ProfileCubit>().pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(AppStrings.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                context.read<ProfileCubit>().pickAvatar(ImageSource.gallery);
              },
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
          backgroundColor: AppColors.dashBg,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────
                _ProfileHeader(
                    onSettings: () => context.push(AppRoutes.editProfile)),

                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar + name ────────────────────
                      Row(children: [
                        GestureDetector(
                          onTap: () => _showAvatarPicker(context),
                          child: Stack(children: [
                            CircleAvatar(
                              radius: 28.r,
                              backgroundColor: AppColors.cardBorder,
                              backgroundImage: state.avatarFile != null
                                  ? FileImage(state.avatarFile as File)
                                  : null,
                              child: state.avatarFile == null
                                  ? Icon(Icons.person,
                                      size: 28.w, color: AppColors.textBody)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 16.w, height: 16.w,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle),
                                child: Icon(Icons.add,
                                    size: 10.w, color: Colors.white),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.fullName,
                                style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            Text(profile.username,
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: AppColors.textBody)),
                          ],
                        ),
                      ]),
                      SizedBox(height: 24.h),

                      // ── Settings label ───────────────────
                      Text(AppStrings.settingsLabel,
                          style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 12.h),

                      // ── Settings items ───────────────────
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
                      SizedBox(height: 32.h),

                      // ── Logout ───────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () => context.go(AppRoutes.login),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.logoutBtn,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(AppStrings.btnLogout,
                              style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
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
      padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 20.h),
      decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient),
      child: Row(
        children: [
          Text(AppStrings.profileTitle,
              style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
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
