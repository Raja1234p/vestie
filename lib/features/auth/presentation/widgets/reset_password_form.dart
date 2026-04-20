import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import '../bloc/reset_password_bloc.dart';
import '../bloc/reset_password_event.dart';
import '../bloc/reset_password_state.dart';
import '../cubit/reset_password_form_cubit.dart';

/// Stateful only for TextEditingController lifecycle — zero setState calls.
class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _newPassCtrl  = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final valid = context
        .read<ResetPasswordFormCubit>()
        .validate(_newPassCtrl.text, _confirmCtrl.text);
    if (valid) {
      context.read<ResetPasswordBloc>().add(
        ResetPasswordSubmitted(newPassword: _newPassCtrl.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordFormCubit, ResetPasswordFormState>(
      builder: (context, form) {
        final isLoading =
            context.watch<ResetPasswordBloc>().state is ResetPasswordLoading;
        final isStrong = ValidationUtils.isPasswordStrong(_newPassCtrl.text);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),

              // ── Back arrow ────────────────────────────────────────
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(Icons.arrow_back,
                    color: AppColors.authTitle, size: 24.w),
              ),
              SizedBox(height: 20.h),

              // ── Title ─────────────────────────────────────────────
              Text(
                AppStrings.resetPasswordTitle,
                style: GoogleFonts.lato(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.authTitle,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                AppStrings.resetPasswordSubtitle,
                style: GoogleFonts.lato(
                  fontSize: 13.5.sp,
                  color: AppColors.authSubtitle,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),

              // ── New password ──────────────────────────────────────
              AppTextField(
                label: AppStrings.labelNewPassword,
                hint: AppStrings.hintNewPassword,
                controller: _newPassCtrl,
                obscureText: !form.newPassVisible,
                textInputAction: TextInputAction.next,
                errorText: form.newPassError,
                onChanged: (_) =>
                    context.read<ResetPasswordFormCubit>().clearNewError(),
                suffixIcon: IconButton(
                  icon: Icon(
                    form.newPassVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20.w,
                    color: AppColors.authHint,
                  ),
                  onPressed: () =>
                      context.read<ResetPasswordFormCubit>().toggleNewPass(),
                ),
              ),
              SizedBox(height: 10.h),

              // ── Strength indicator ────────────────────────────────
              Row(children: [
                Icon(
                  isStrong ? Icons.check_circle : Icons.check_circle_outline,
                  size: 16.w,
                  color: isStrong ? AppColors.validSuccess : AppColors.authHint,
                ),
                SizedBox(width: 6.w),
                Text(
                  AppStrings.passwordHint,
                  style: GoogleFonts.lato(
                    fontSize: 12.sp,
                    color:
                        isStrong ? AppColors.validSuccess : AppColors.authHint,
                  ),
                ),
              ]),
              SizedBox(height: 14.h),

              // ── Confirm password ──────────────────────────────────
              AppTextField(
                label: AppStrings.labelConfirmNewPass,
                hint: AppStrings.hintConfirmNewPass,
                controller: _confirmCtrl,
                obscureText: !form.confirmVisible,
                textInputAction: TextInputAction.done,
                errorText: form.confirmError,
                onChanged: (_) =>
                    context.read<ResetPasswordFormCubit>().clearConfirmError(),
                suffixIcon: IconButton(
                  icon: Icon(
                    form.confirmVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20.w,
                    color: AppColors.authHint,
                  ),
                  onPressed: () =>
                      context.read<ResetPasswordFormCubit>().toggleConfirm(),
                ),
              ),
              SizedBox(height: 28.h),

              // ── Reset password button ─────────────────────────────
              AppButton(
                text: AppStrings.btnResetPassword,
                isLoading: isLoading,
                onPressed: () => _submit(context),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}
