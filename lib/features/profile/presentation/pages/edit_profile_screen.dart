import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_sub_header.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.read<ProfileCubit>().state.profile;
    return BlocProvider(
      create: (_) => EditProfileCubit(profile),
      child: const _EditProfileBody(),
    );
  }
}

class _EditProfileBody extends StatefulWidget {
  const _EditProfileBody();
  @override
  State<_EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<_EditProfileBody> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<EditProfileCubit>().state;
    _nameCtrl  = TextEditingController(text: s.fullName);
    _userCtrl  = TextEditingController(text: s.username);
    _emailCtrl = TextEditingController(text: s.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _userCtrl.dispose(); _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state.saved) {
          AppSnackBar.showSuccess(context, AppStrings.profileUpdatedSuccess);
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final cubit = context.read<EditProfileCubit>();
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                ProfileSubHeader(title: AppStrings.editProfileTitle),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      _FieldLabel(AppStrings.labelFullName2),
                      _ProfileField(
                          controller: _nameCtrl,
                          hint: AppStrings.hintCardHolder,
                          onChanged: cubit.setFullName),
                      SizedBox(height: 16.h),
                      _FieldLabel(AppStrings.labelUsername),
                      _ProfileField(
                          controller: _userCtrl,
                          hint: AppStrings.hintUsername,
                          onChanged: cubit.setUsername),
                      SizedBox(height: 16.h),
                      _FieldLabel(AppStrings.labelEmail),
                      _ProfileField(
                          controller: _emailCtrl,
                          hint: AppStrings.hintEmail,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: cubit.setEmail),
                      SizedBox(height: 32.h),
                      if (state.isSaving)
                        const AppLoader()
                      else
                        AppButton(
                          text: AppStrings.btnSaveChanges,
                          onPressed: () async {
                            final updated = await cubit.save();
                            if (updated != null && context.mounted) {
                              context.read<ProfileCubit>().updateProfile(updated);
                            }
                          },
                        ),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(text,
          style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody)),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const _ProfileField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: GoogleFonts.lato(fontSize: 14.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(fontSize: 14.sp, color: AppColors.authHint),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        ),
      ),
    );
  }
}
