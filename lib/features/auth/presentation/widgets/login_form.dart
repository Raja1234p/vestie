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
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../cubit/login_form_cubit.dart';
import 'or_divider.dart';
import 'social_auth_button.dart';

/// Stateful only for TextEditingController lifecycle — zero setState calls.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showComingSoon(BuildContext context) =>
      AppSnackBar.showInfo(context, AppStrings.socialComingSoon);

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    final formCubit = context.read<LoginFormCubit>();
    final valid = formCubit.validate(_emailCtrl.text, _passCtrl.text);
    if (valid) {
      context.read<LoginBloc>().add(LoginSubmitted(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginFormCubit, LoginFormState>(
      builder: (context, form) {
        final isLoading =
            context.watch<LoginBloc>().state is LoginLoading;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),
              Text(AppStrings.loginTitle,
                  style: GoogleFonts.inter(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authTitle,
                      height: 1.2)),
              SizedBox(height: 6.h),
              Text(AppStrings.loginSubtitle,
                  style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      color: AppColors.authSubtitle,
                      height: 1.5)),
              SizedBox(height: 32.h),
              AppTextField(
                label: AppStrings.labelEmail,
                hint: AppStrings.hintEmail,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                errorText: form.emailError,
                onChanged: (_) =>
                    context.read<LoginFormCubit>().clearEmailError(),
              ),
              SizedBox(height: 16.h),
              AppTextField(
                label: AppStrings.labelPassword,
                hint: AppStrings.hintPassword,
                controller: _passCtrl,
                obscureText: !form.passwordVisible,
                textInputAction: TextInputAction.done,
                errorText: form.passwordError,
                onChanged: (_) =>
                    context.read<LoginFormCubit>().clearPasswordError(),
                suffixIcon: IconButton(
                  icon: Icon(
                    form.passwordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20.w,
                    color: AppColors.authHint,
                  ),
                  onPressed: () =>
                      context.read<LoginFormCubit>().togglePassword(),
                ),
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 32.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(AppStrings.forgotPassword,
                      style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          color: AppColors.authForgotLink,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.authForgotLink)),
                ),
              ),
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
                onPressed: () => _showComingSoon(context),
              ),
              SizedBox(height: 12.h),
              SocialAuthButton(
                provider: SocialProvider.apple,
                onPressed: () => _showComingSoon(context),
              ),
              SizedBox(height: 40.h),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                        fontSize: 13.sp, color: AppColors.authBottomText),
                    children: [
                      TextSpan(text: AppStrings.noAccount),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => context.go(AppRoutes.register),
                          child: Text(AppStrings.signupLink,
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
