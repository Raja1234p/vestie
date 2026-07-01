import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import 'auth_password_visibility_icon.dart';
import '../../../../core/utils/person_name_input_formatter.dart';
import '../../../../app/router/app_routes.dart';
import 'register_password_requirement_bar.dart';
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
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    final formCubit = context.read<RegisterFormCubit>();
    final isValid = formCubit.validate(
      _nameCtrl.text,
      _emailCtrl.text,
      _passCtrl.text,
      _confirmCtrl.text,
    );
    if (!isValid) return;

    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        confirmPassword: _confirmCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
      builder: (context, form) {
        final registerState = context.watch<RegisterBloc>().state;
        final isEmailLoading = registerState is RegisterLoading;
        final isGoogleLoading = registerState is RegisterGoogleLoading;
        final isAppleLoading = registerState is RegisterAppleLoading;
        final isSocialLoading = isGoogleLoading || isAppleLoading;
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 48.h),
                  Text(
                    AppStrings.registerTitle,
                    style: GoogleFonts.lato(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authTitle,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    AppStrings.registerSubtitle,
                    style: GoogleFonts.lato(
                      fontSize: 18.sp,
                      color: AppColors.authSubtitle,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: AppStrings.labelFullName,
                    hint: AppStrings.hintFullName,
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      PersonNameInputFormatter(allowSpaces: true),
                    ],
                    errorText: form.nameError,
                    onChanged: (_) =>
                        context.read<RegisterFormCubit>().onFieldsChanged(
                          _nameCtrl.text,
                          _emailCtrl.text,
                          _passCtrl.text,
                          _confirmCtrl.text,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: AppStrings.labelEmail,
                    hint: AppStrings.hintEmail,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    errorText: form.emailError,
                    onChanged: (_) =>
                        context.read<RegisterFormCubit>().onFieldsChanged(
                          _nameCtrl.text,
                          _emailCtrl.text,
                          _passCtrl.text,
                          _confirmCtrl.text,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: AppStrings.labelPassword,
                    hint: AppStrings.hintCreatePassword,
                    controller: _passCtrl,
                    obscureText: !form.passwordVisible,
                    errorText: form.passwordError,
                    onChanged: (_) =>
                        context.read<RegisterFormCubit>().onFieldsChanged(
                          _nameCtrl.text,
                          _emailCtrl.text,
                          _passCtrl.text,
                          _confirmCtrl.text,
                        ),
                    suffixIcon: ExcludeFocus(
                      child: IconButton(
                        icon: AuthPasswordVisibilityIcon(
                          passwordVisible: form.passwordVisible,
                          logicalSize: 20.w,
                        ),
                        onPressed: () =>
                            context.read<RegisterFormCubit>().togglePassword(),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: AppStrings.labelConfirmPassword,
                    hint: AppStrings.hintConfirmPassword,
                    controller: _confirmCtrl,
                    obscureText: !form.confirmVisible,
                    textInputAction: TextInputAction.done,
                    errorText: form.confirmError,
                    onChanged: (_) =>
                        context.read<RegisterFormCubit>().onFieldsChanged(
                          _nameCtrl.text,
                          _emailCtrl.text,
                          _passCtrl.text,
                          _confirmCtrl.text,
                        ),
                    suffixIcon: ExcludeFocus(
                      child: IconButton(
                        icon: AuthPasswordVisibilityIcon(
                          passwordVisible: form.confirmVisible,
                          logicalSize: 20.w,
                        ),
                        onPressed: () =>
                            context.read<RegisterFormCubit>().toggleConfirm(),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  RegisterPasswordRequirementBar(),
                  SizedBox(height: 24.h),
                  AppButton(
                    text: AppStrings.btnContinue,
                    isLoading: isEmailLoading,
                    onPressed: isEmailLoading || isSocialLoading
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
                            : () => context.read<RegisterBloc>().add(
                                const GoogleRegisterRequested(),
                              ),
                      ),
                    if (Platform.isIOS)
                      SocialAuthButton(
                        provider: SocialProvider.apple,
                        isLoading: isAppleLoading,
                        onPressed: isEmailLoading || isSocialLoading
                            ? null
                            : () => context.read<RegisterBloc>().add(
                                const AppleRegisterRequested(),
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
                        AppStrings.hasAccount,
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.authBottomText,
                          height: 1.35,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          AppStrings.loginLink,
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
        );
      },
    );
  }
}
