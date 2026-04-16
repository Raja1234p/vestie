import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../app/router/app_routes.dart';
import '../bloc/verification_cubit.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_gradient_button.dart';
import '../widgets/auth_text_field.dart';

class VerifyScreen extends StatefulWidget {
  final String email;
  const VerifyScreen({super.key, required this.email});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _codeCtrl = TextEditingController();
  String? _codeError;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final err = ValidationUtils.validateOtpCode(_codeCtrl.text);
    setState(() => _codeError = err);
    return err == null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerificationCubit(email: widget.email),
      child: BlocConsumer<VerificationCubit, VerificationState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.go(AppRoutes.agreement);
          }
        },
        builder: (context, state) {
          final cubit = context.read<VerificationCubit>();
          return AuthBackground(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 48.h),

                  // ── Title ─────────────────────────────────────────
                  Text(
                    AppStrings.verifyTitle,
                    style: GoogleFonts.lato(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authTitle,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    AppStrings.verifySubtitle,
                    style: GoogleFonts.lato(
                      fontSize: 13.5.sp,
                      color: AppColors.authSubtitle,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // ── OTP Field ─────────────────────────────────────
                  AuthTextField(
                    label: AppStrings.labelVerifyCode,
                    hint: AppStrings.hintVerifyCode,
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: 6,
                    errorText: state.error ?? _codeError,
                    onChanged: (_) => setState(() => _codeError = null),
                  ),
                  SizedBox(height: 28.h),

                  // ── Verify Button ─────────────────────────────────
                  AuthGradientButton(
                    text: AppStrings.btnVerify,
                    isLoading: state.isLoading,
                    onPressed: () {
                      if (_validate()) {
                        cubit.verifyCode(_codeCtrl.text.trim());
                      }
                    },
                  ),
                  SizedBox(height: 22.h),

                  // ── Resend ────────────────────────────────────────
                  Center(
                    child: RichText(
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
                                        decorationColor: AppColors.authBottomLink,
                                      ),
                                    ),
                                  )
                                : Text(
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
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
