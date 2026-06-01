import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import 'auth_go_back_button.dart';
import '../../../../core/widgets/common/app_button.dart';
import 'auth_password_visibility_icon.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import 'register_password_requirement_bar.dart';
import '../bloc/reset_password_bloc.dart';
import '../bloc/reset_password_event.dart';
import '../bloc/reset_password_state.dart';
import '../cubit/reset_password_form_cubit.dart';

/// New password + confirm only — OTP was verified on the shared [VerifyScreen].
class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({
    super.key,
    required this.email,
    required this.code,
  });

  final String email;
  final String code;

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final valid = context.read<ResetPasswordFormCubit>().validate(
          _newPassCtrl.text,
          _confirmCtrl.text,
        );

    if (valid && widget.code.length == 6) {
      context.read<ResetPasswordBloc>().add(
            ResetPasswordSubmitted(
              email: widget.email,
              code: widget.code,
              newPassword: _newPassCtrl.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordFormCubit, ResetPasswordFormState>(
      builder: (context, form) {
        final isLoading =
            context.watch<ResetPasswordBloc>().state is ResetPasswordLoading;
        final canSubmit = form.isValid && widget.code.length == 6;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),
              AuthGoBackButton(
                onPressed: () {
                  _newPassCtrl.clear();
                  _confirmCtrl.clear();
                  context.read<ResetPasswordFormCubit>().reset();
                  context.pop();
                },
              ),
              SizedBox(height: 20.h),
              Text(
                AppStrings.resetPasswordTitle,
                style: GoogleFonts.lato(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.authTitle,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                AppStrings.resetPasswordSubtitle,
                style: GoogleFonts.lato(
                  fontSize: 13.5.sp,
                  color: AppColors.authSubtitle,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 12.h),
              AppTextField(
                label: AppStrings.labelNewPassword,
                hint: AppStrings.hintNewPassword,
                controller: _newPassCtrl,
                obscureText: !form.newPassVisible,
                textInputAction: TextInputAction.next,
                errorText: form.newPassError,
                onChanged: (_) =>
                    context.read<ResetPasswordFormCubit>().onFieldsChanged(
                          _newPassCtrl.text,
                          _confirmCtrl.text,
                        ),
                suffixIcon: ExcludeFocus(
                  child: IconButton(
                    icon: AuthPasswordVisibilityIcon(
                      passwordVisible: form.newPassVisible,
                      logicalSize: 20.w,
                    ),
                    onPressed: () =>
                        context.read<ResetPasswordFormCubit>().toggleNewPass(),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              AppTextField(
                label: AppStrings.labelConfirmNewPass,
                hint: AppStrings.hintConfirmNewPass,
                controller: _confirmCtrl,
                obscureText: !form.confirmVisible,
                textInputAction: TextInputAction.done,
                errorText: form.confirmError,
                onChanged: (_) =>
                    context.read<ResetPasswordFormCubit>().onFieldsChanged(
                          _newPassCtrl.text,
                          _confirmCtrl.text,
                        ),
                suffixIcon: ExcludeFocus(
                  child: IconButton(
                    icon: AuthPasswordVisibilityIcon(
                      passwordVisible: form.confirmVisible,
                      logicalSize: 20.w,
                    ),
                    onPressed: () =>
                        context.read<ResetPasswordFormCubit>().toggleConfirm(),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              RegisterPasswordRequirementBar(),
              SizedBox(height: 24.h),
              AppButton(
                text: AppStrings.btnResetPassword,
                isLoading: isLoading,
                onPressed: canSubmit ? () => _submit(context) : null,
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }
}
