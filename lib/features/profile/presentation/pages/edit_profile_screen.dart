import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/person_name_input_formatter.dart';
import '../../../../core/utils/username_input_formatter.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../../../core/widgets/common/flow_screen_footer.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/edit_profile_cubit.dart';
import '../widgets/profile_sub_header.dart';

/// Loads `GET /users/me` (with prefs fallback) so fields match the API, then
/// saves via `PUT /users/me` and shows the returned profile on this screen.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  UserProfile? _profile;
  String _photoUrl = '';
  bool _loading = true;
  String? _loadWarning;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _loadWarning = null;
    });

    final prefs = ServiceLocator.instance.sharedPrefs;
    final name = await prefs.getString(StorageKeys.userName) ?? '';
    final email = await prefs.getString(StorageKeys.userEmail) ?? '';
    final storedHandle = await prefs.getString(StorageKeys.userUsername) ?? '';
    final fallbackUsername = storedHandle.isNotEmpty
        ? storedHandle
        : (email.contains('@') ? email.split('@').first : '');

    final result = await ServiceLocator.instance.authRepository.getMe();
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _loading = false;
          _loadWarning = failure.message;
          _profile = UserProfile(
            fullName: name,
            username: fallbackUsername,
            email: email,
          );
          _photoUrl = '';
        });
      },
      (user) {
        final userName = user.userName.isNotEmpty
            ? user.userName
            : (user.email.contains('@')
                ? user.email.split('@').first
                : '');
        setState(() {
          _loading = false;
          _loadWarning = null;
          _profile = UserProfile(
            fullName: user.name,
            username: userName,
            email: user.email,
          );
          _photoUrl = user.photoUrl ?? '';
        });
        prefs.saveString(StorageKeys.userName, user.name);
        prefs.saveString(StorageKeys.userEmail, user.email);
        prefs.saveString(StorageKeys.userUsername, userName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profile == null) {
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

    return BlocProvider(
      create: (_) => EditProfileCubit(
        _profile!,
        photoUrlForApi: _photoUrl,
      ),
      child: _EditProfileBody(
        loadWarning: _loadWarning,
        onRetryLoad: _bootstrap,
      ),
    );
  }
}

class _EditProfileBody extends StatefulWidget {
  const _EditProfileBody({
    required this.loadWarning,
    required this.onRetryLoad,
  });

  final String? loadWarning;
  final VoidCallback onRetryLoad;

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (prev, curr) =>
          prev.lastSavedFromServer == null &&
          curr.lastSavedFromServer != null,
      listener: (context, state) {
        final p = state.lastSavedFromServer;
        if (p == null) return;
        _nameCtrl.text = state.fullName;
        _userCtrl.text = state.username;
        _emailCtrl.text = state.email;
        AppSnackBar.showSuccess(context, AppStrings.profileUpdatedSuccess);
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
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.loadWarning != null) ...[
                          _LoadWarningBanner(
                            message: widget.loadWarning!,
                            onRetry: widget.onRetryLoad,
                          ),
                          SizedBox(height: 16.h),
                        ],
                        if (state.lastSavedFromServer != null) ...[
                          _UpdatedProfileBanner(profile: state.lastSavedFromServer!),
                          SizedBox(height: 16.h),
                        ],
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
                    isLoading: state.isSaving,
                    onPressed: state.isSaving ? null : () => cubit.save(),
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

class _LoadWarningBanner extends StatelessWidget {
  const _LoadWarningBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 8.h),
          AppButton(
            text: AppStrings.btnRetry,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _UpdatedProfileBanner extends StatelessWidget {
  const _UpdatedProfileBanner({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.profileUpdatedSuccess,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            profile.fullName,
            style: GoogleFonts.lato(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (profile.username.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              '@${profile.username}',
              style: GoogleFonts.lato(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textBody,
              ),
            ),
          ],
          SizedBox(height: 4.h),
          Text(
            profile.email,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
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
            color: readOnly ? AppColors.appBgBottom : Colors.white,
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
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
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
