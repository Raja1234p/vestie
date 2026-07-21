import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_loading_overlay.dart';
import 'auth_password_visibility_icon.dart';
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
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    final formCubit = context.read<LoginFormCubit>();
    final valid = formCubit.validate(_emailCtrl.text, _passCtrl.text);
    if (valid) {
      context.read<LoginBloc>().add(
        LoginSubmitted(email: _emailCtrl.text.trim(), password: _passCtrl.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginFormCubit, LoginFormState>(
      builder: (context, form) {
        final loginState = context.watch<LoginBloc>().state;
        final isEmailLoading = loginState is LoginLoading;
        final isGoogleLoading = loginState is LoginGoogleLoading;
        final isAppleLoading = loginState is LoginAppleLoading;
        final isSocialLoading = isGoogleLoading || isAppleLoading;
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        // Overlay covers Apple sheet follow-up (/auth/apple, GET/PUT /users/me).
        return AppLoadingOverlay(
          isLoading: isAppleLoading,
          child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 70.h),
                  Text(
                    AppStrings.loginTitle,
                    style: GoogleFonts.lato(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authTitle,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    AppStrings.loginSubtitle,
                    style: GoogleFonts.lato(
                      fontSize: 18.sp,
                      color: AppColors.authSubtitle,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: AppStrings.labelEmail,
                    hint: AppStrings.hintEmail,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    errorText: form.emailError,
                    onChanged: (_) => context
                        .read<LoginFormCubit>()
                        .onFieldsChanged(_emailCtrl.text, _passCtrl.text),
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: AppStrings.labelPassword,
                    hint: AppStrings.hintPassword,
                    controller: _passCtrl,
                    obscureText: !form.passwordVisible,
                    textInputAction: TextInputAction.done,
                    errorText: form.passwordError,
                    onChanged: (_) => context
                        .read<LoginFormCubit>()
                        .onFieldsChanged(_emailCtrl.text, _passCtrl.text),
                    suffixIcon: ExcludeFocus(
                      child: IconButton(
                        icon: AuthPasswordVisibilityIcon(
                          passwordVisible: form.passwordVisible,
                          logicalSize: 20.w,
                        ),
                        onPressed: () =>
                            context.read<LoginFormCubit>().togglePassword(),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        await context.push(AppRoutes.forgotPassword);
                        if (!context.mounted) return;
                        _emailCtrl.clear();
                        _passCtrl.clear();
                        context.read<LoginFormCubit>().reset();
                        context.read<LoginBloc>().add(const LoginReset());
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 32.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.forgotPassword,
                        style: GoogleFonts.lato(
                          fontSize: 12.5.sp,
                          color: AppColors.authForgotLink,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.authForgotLink,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppButton(
                    text: AppStrings.btnContinue,
                    isLoading: isEmailLoading,
                    onPressed:
                        isEmailLoading || isSocialLoading || !form.isValid
                        ? null
                        : () => _submit(context),
                  ),
                  if (Platform.isAndroid || Platform.isIOS) ...[
                    SizedBox(height: 12.h),
                    const OrDivider(),
                    SizedBox(height: 12.h),
                    if (Platform.isAndroid)
                      SocialAuthButton(
                        provider: SocialProvider.google,
                        isLoading: isGoogleLoading,
                        onPressed: isEmailLoading || isSocialLoading
                            ? null
                            : () => context.read<LoginBloc>().add(
                                const GoogleLoginRequested(),
                              ),
                      ),
                    if (Platform.isIOS)
                      SocialAuthButton(
                        provider: SocialProvider.apple,
                        isLoading: isAppleLoading,
                        onPressed: isEmailLoading || isSocialLoading
                            ? null
                            : () => context.read<LoginBloc>().add(
                                const AppleLoginRequested(),
                              ),
                      ),
                  ],
                  SizedBox(height: 12.h),
                ]),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24.w,
                  8.h,
                  24.w,
                  16.h + bottomInset,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        AppStrings.noAccount,
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.authBottomText,
                          height: 1.35,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.register),
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          AppStrings.signupLink,
                          style: GoogleFonts.lato(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.authBottomLink,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        );
      },
    );
  }
}
