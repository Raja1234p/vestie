import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/person_name_input_formatter.dart';
import '../../../../core/utils/username_input_formatter.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../../../core/widgets/common/app_toast.dart';
import '../../../../core/widgets/common/flow_screen_footer.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../data/profile_prefs.dart';
import '../cubit/edit_profile_cubit.dart';
import '../widgets/profile_sub_header.dart';

/// Edit profile — fields from dashboard-cached prefs; save then `GET /users/me` sync.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  EditProfileCubit? _cubit;

  @override
  void initState() {
    super.initState();
    ProfilePrefs.load().then((profile) {
      if (!mounted) return;
      setState(() => _cubit = EditProfileCubit(profile));
    });
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    if (cubit == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: PostAuthGradientBackground(
          child: Column(
            children: [
              ProfileSubHeader(title: AppStrings.editProfileTitle),
              const Expanded(child: Center(child: AppLoader())),
            ],
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: cubit,
      child: const _EditProfileForm(),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm();

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<EditProfileCubit>().state;
    _nameCtrl = TextEditingController(text: s.fullName);
    _userCtrl = TextEditingController(text: s.username);
    _emailCtrl = TextEditingController(text: s.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cubit = context.read<EditProfileCubit>();
    if (cubit.state.isSaving) return;

    final updated = await cubit.save();
    if (!mounted) return;
    if (updated == null) {
      final message = cubit.state.error;
      if (message != null && message.isNotEmpty) {
        AppToast.showError(context, message);
      }
      return;
    }

    _nameCtrl.text = updated.fullName;
    _userCtrl.text = updated.username;
    _emailCtrl.text = updated.email;
    AppToast.showSuccess(context, AppStrings.profileUpdatedSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
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
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileFieldGroup(
                          label: AppStrings.labelFullName2,
                          controller: _nameCtrl,
                          hint: AppStrings.hintCardHolder,
                          errorText: state.fullNameError,
                          inputFormatters: [
                            PersonNameInputFormatter(allowSpaces: true),
                          ],
                          onChanged: cubit.setFullName,
                        ),
                        SizedBox(height: 16.h),
                        _ProfileFieldGroup(
                          label: AppStrings.labelUsername,
                          controller: _userCtrl,
                          hint: AppStrings.hintUsername,
                          errorText: state.usernameError,
                          inputFormatters: const [UsernameInputFormatter()],
                          onChanged: cubit.setUsername,
                        ),
                        SizedBox(height: 16.h),
                        _ProfileFieldGroup(
                          label: AppStrings.labelEmail,
                          controller: _emailCtrl,
                          hint: AppStrings.hintEmail,
                          errorText: state.emailError,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                          onChanged: (_) {},
                        ),
                        if (state.error != null && state.error!.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(
                            state.error!,
                            style: GoogleFonts.lato(
                              fontSize: 12.sp,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                FlowScreenFooter(
                  child: AppButton(
                    text: AppStrings.btnSaveChanges,
                    useGradient: false,
                    hasShadow: false,
                    color: AppColors.neutral1200,
                    borderRadius: AppRadius.r8,
                    isLoading: state.isSaving,
                    onPressed: state.isSaving ? null : _save,
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

class _ProfileFieldGroup extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;
  final bool readOnly;

  const _ProfileFieldGroup({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.appBgBottom,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.inputFieldBorder,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.inputFieldText,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.lato(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.authHint,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text(
            errorText!,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
