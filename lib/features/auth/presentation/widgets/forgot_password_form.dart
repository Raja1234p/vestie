import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';
import '../cubit/forgot_password_form_cubit.dart';

/// Stateful only for TextEditingController lifecycle — zero setState calls.
class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final valid =
        context.read<ForgotPasswordFormCubit>().validate(_emailCtrl.text);
    if (valid) {
      context.read<ForgotPasswordBloc>().add(
            ForgotPasswordSubmitted(email: _emailCtrl.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgotPasswordFormCubit, ForgotPasswordFormState>(
      builder: (context, form) {
        final isLoading =
            context.watch<ForgotPasswordBloc>().state is ForgotPasswordLoading;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),

              // ── Back arrow ────────────────────────────────────────
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.authTitle,
                  size: 20.w,
                ),
              ),
              SizedBox(height: 20.h),

              // ── Title ─────────────────────────────────────────────
              Text(
                AppStrings.forgotTitle,
                style: GoogleFonts.inter(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.authTitle,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                AppStrings.forgotSubtitle,
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  color: AppColors.authSubtitle,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),

              // ── Email field ───────────────────────────────────────
              AppTextField(
                label: AppStrings.labelEmailAddress,
                hint: AppStrings.hintRegisteredEmail,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                errorText: form.emailError,
                onChanged: (_) =>
                    context.read<ForgotPasswordFormCubit>().clearError(),
              ),
              SizedBox(height: 28.h),

              // ── Send reset email button ───────────────────────────
              AppButton(
                text: AppStrings.btnSendResetEmail,
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
