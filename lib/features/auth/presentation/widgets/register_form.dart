import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import '../../../../app/router/app_routes.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../cubit/register_form_cubit.dart';
import 'or_divider.dart';
import 'social_auth_button.dart';

/// Stateful only for TextEditingController lifecycle — zero setState calls.
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nameCtrl        = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passCtrl        = TextEditingController();
  final _confirmCtrl     = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _showComingSoon(BuildContext context) =>
      AppSnackBar.showInfo(context, AppStrings.socialComingSoon);

  void _submit(BuildContext context) {
    final valid = context.read<RegisterFormCubit>().validate(
          _nameCtrl.text,
          _emailCtrl.text,
          _passCtrl.text,
          _confirmCtrl.text,
        );
    if (valid) {
      context.read<RegisterBloc>().add(RegisterSubmitted(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
      builder: (context, form) {
        final isLoading =
            context.watch<RegisterBloc>().state is RegisterLoading;
        final isStrong =
            _passCtrl.text.length >= 8 && _passCtrl.text.contains(RegExp(r'[a-zA-Z]')) && _passCtrl.text.contains(RegExp(r'[0-9]'));
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),
              Text(AppStrings.registerTitle,
                  style: GoogleFonts.inter(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authTitle,
                      height: 1.2)),
              SizedBox(height: 6.h),
              Text(AppStrings.registerSubtitle,
                  style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      color: AppColors.authSubtitle,
                      height: 1.5)),
              SizedBox(height: 28.h),
              AppTextField(
                label: AppStrings.labelFullName,
                hint: AppStrings.hintFullName,
                controller: _nameCtrl,
                keyboardType: TextInputType.name,
                errorText: form.nameError,
                onChanged: (_) =>
                    context.read<RegisterFormCubit>().clearNameError(),
              ),
              SizedBox(height: 14.h),
              AppTextField(
                label: AppStrings.labelEmail,
                hint: AppStrings.hintEmail,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                errorText: form.emailError,
                onChanged: (_) =>
                    context.read<RegisterFormCubit>().clearEmailError(),
              ),
              SizedBox(height: 14.h),
              AppTextField(
                label: AppStrings.labelPassword,
                hint: AppStrings.hintCreatePassword,
                controller: _passCtrl,
                obscureText: !form.passwordVisible,
                errorText: form.passwordError,
                onChanged: (_) =>
                    context.read<RegisterFormCubit>().clearPasswordError(),
                suffixIcon: IconButton(
                  icon: Icon(
                    form.passwordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20.w,
                    color: AppColors.authHint,
                  ),
                  onPressed: () =>
                      context.read<RegisterFormCubit>().togglePassword(),
                ),
              ),
              SizedBox(height: 14.h),
              AppTextField(
                label: AppStrings.labelConfirmPassword,
                hint: AppStrings.hintConfirmPassword,
                controller: _confirmCtrl,
                obscureText: !form.confirmVisible,
                textInputAction: TextInputAction.done,
                errorText: form.confirmError,
                onChanged: (_) =>
                    context.read<RegisterFormCubit>().clearConfirmError(),
                suffixIcon: IconButton(
                  icon: Icon(
                    form.confirmVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20.w,
                    color: AppColors.authHint,
                  ),
                  onPressed: () =>
                      context.read<RegisterFormCubit>().toggleConfirm(),
                ),
              ),
              SizedBox(height: 10.h),
              Row(children: [
                Icon(
                  isStrong ? Icons.check_circle : Icons.check_circle_outline,
                  size: 16.w,
                  color: isStrong ? AppColors.validSuccess : AppColors.authHint,
                ),
                SizedBox(width: 6.w),
                Text(AppStrings.passwordHint,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: isStrong
                            ? AppColors.validSuccess
                            : AppColors.authHint)),
              ]),
              SizedBox(height: 24.h),
              AppButton(
                text: AppStrings.btnContinue,
                isLoading: isLoading,
                onPressed: () => _submit(context),
              ),
              SizedBox(height: 22.h),
              const OrDivider(),
              SizedBox(height: 20.h),
              SocialAuthButton(
                  provider: SocialProvider.google,
                  onPressed: () => _showComingSoon(context)),
              SizedBox(height: 12.h),
              SocialAuthButton(
                  provider: SocialProvider.apple,
                  onPressed: () => _showComingSoon(context)),
              SizedBox(height: 32.h),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                        fontSize: 13.sp, color: AppColors.authBottomText),
                    children: [
                      TextSpan(text: AppStrings.hasAccount),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: Text(AppStrings.loginLink,
                              style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: AppColors.authBottomLink,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.authBottomLink)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}
