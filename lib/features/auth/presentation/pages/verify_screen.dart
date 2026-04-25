import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/widgets/common/app_failure_dialog.dart';
import '../bloc/verification_cubit.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_gradient_button.dart';
import '../widgets/auth_text_field.dart';
import '../../../../core/widgets/text/app_text.dart';

class VerifyScreen extends StatelessWidget {
  final String email;
  VerifyScreen({super.key, required this.email});

  final _codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerificationCubit(email: email),
      child: BlocListener<VerificationCubit, VerificationState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.go(AppRoutes.agreement);
          } else if (state.error != null) {
            AppFailureDialog.show(
              context,
              title: state.title,
              message: state.error!,
            );
            context.read<VerificationCubit>().clearError();
          }
        },
        child: AuthBackground(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.h),

                // ── Title ─────────────────────────────────────────
                AppText(
                  AppStrings.verifyTitle,
                  style: GoogleFonts.lato(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.authTitle,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6.h),
                AppText(
                  AppStrings.verifySubtitle,
                  style: GoogleFonts.lato(
                    fontSize: 13.5.sp,
                    color: AppColors.authSubtitle,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),

                // ── OTP Field ─────────────────────────────────────
                BlocBuilder<VerificationCubit, VerificationState>(
                  buildWhen: (prev, curr) => prev.error != curr.error,
                  builder: (context, state) {
                    return AuthTextField(
                      label: AppStrings.labelVerifyCode,
                      hint: AppStrings.hintVerifyCode,
                      controller: _codeCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      errorText: state.error,
                      onChanged: (val) => context.read<VerificationCubit>().onCodeChanged(val),
                    );
                  },
                ),
                SizedBox(height: 28.h),

                // ── Verify Button ─────────────────────────────────
                BlocBuilder<VerificationCubit, VerificationState>(
                  buildWhen: (prev, curr) => 
                      prev.isLoading != curr.isLoading || 
                      prev.isValid != curr.isValid,
                  builder: (context, state) {
                    return AuthGradientButton(
                      text: AppStrings.btnVerify,
                      isLoading: state.isLoading,
                      onPressed: state.isValid ? () {
                        context
                            .read<VerificationCubit>()
                            .verifyCode(_codeCtrl.text.trim());
                      } : null,
                    );
                  },
                ),
                SizedBox(height: 22.h),

                // ── Resend ────────────────────────────────────────
                Center(
                  child: BlocBuilder<VerificationCubit, VerificationState>(
                    buildWhen: (prev, curr) =>
                        prev.resendSeconds != curr.resendSeconds ||
                        prev.canResend != curr.canResend,
                    builder: (context, state) {
                      final cubit = context.read<VerificationCubit>();
                      return RichText(
                        text: TextSpan(
                          style: GoogleFonts.lato(
                            fontSize: 13.sp,
                            color: AppColors.authBottomText,
                          ),
                          children: [
                            TextSpan(text: AppStrings.didntReceive),
                            WidgetSpan(
                              child: state.canResend
                                  ? GestureDetector(
                                      onTap: cubit.resendCode,
                                      child: Text(
                                        AppStrings.resendCode,
                                        style: GoogleFonts.lato(
                                          fontSize: 13.sp,
                                          color: AppColors.authBottomLink,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              AppColors.authBottomLink,
                                        ),
                                      ),
                                    )
                                  : AppText(
                                      '${AppStrings.resendCode} (${state.resendSeconds}s)',
                                      style: GoogleFonts.lato(
                                        fontSize: 13.sp,
                                        color: AppColors.authBottomText
                                            .withValues(alpha: 0.55),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
