import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_go_back_button.dart';
import '../../../../core/widgets/common/app_failure_dialog.dart';
import '../../../../core/widgets/common/app_toast.dart';
import '../../../../core/widgets/common/app_loading_dialog.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../bloc/verification_cubit.dart';
import '../models/auth_route_extras.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_gradient_button.dart';
import '../widgets/auth_text_field.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({
    super.key,
    required this.email,
    this.flow = VerifyFlow.registration,
  });

  final String email;
  final VerifyFlow flow;

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerificationCubit(
        email: widget.email,
        flow: widget.flow,
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<VerificationCubit, VerificationState>(
            listenWhen: (prev, curr) =>
                !prev.isResending && curr.isResending,
            listener: (context, _) {
              final cubit = context.read<VerificationCubit>();
              showDialog<void>(
                context: context,
                useRootNavigator: true,
                barrierDismissible: false,
                barrierColor: Colors.black.withValues(alpha: 0.35),
                builder: (dialogContext) {
                  return BlocProvider.value(
                    value: cubit,
                    child: BlocListener<VerificationCubit, VerificationState>(
                      listenWhen: (prev, curr) =>
                          prev.isResending && !curr.isResending,
                      listener: (_, s) {
                        if (s.isResending) return;
                        final nav = Navigator.of(dialogContext);
                        if (nav.canPop()) nav.pop();
                      },
                      child: AppLoadingDialog.body(
                        message: AppStrings.loadingResendOtp,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          BlocListener<VerificationCubit, VerificationState>(
            listenWhen: (prev, curr) =>
                prev.isSuccess != curr.isSuccess ||
                prev.error != curr.error ||
                prev.resendMessage != curr.resendMessage,
            listener: (context, state) async {
              if (state.isSuccess) {
                if (widget.flow == VerifyFlow.registration) {
                  context.go(AppRoutes.agreement);
                } else {
                  final code = _codeCtrl.text.trim();
                  final verificationCubit = context.read<VerificationCubit>();
                  await context.push(
                    AppRoutes.resetPassword,
                    extra: ResetPasswordExtra(email: widget.email, code: code),
                  );
                  if (!mounted) return;
                  _codeCtrl.clear();
                  verificationCubit.clearCodeAfterResetPasswordRoutePopped();
                }
              } else if (state.error != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  AppFailureDialog.show(
                    context,
                    title: state.title,
                    message: state.error!,
                  );
                  context.read<VerificationCubit>().clearError();
                });
              } else if (state.resendMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  final msg = state.resendMessage!.trim();
                  AppToast.showSuccess(
                    context,
                    msg.isNotEmpty
                        ? msg
                        : AppStrings.otpSentSuccessToast,
                  );
                  context.read<VerificationCubit>().clearResendMessage();
                });
              }
            },
          ),
        ],
        child: AuthBackground(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.h),
                AuthGoBackButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    if (widget.flow == VerifyFlow.forgotPassword) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.register);
                    }
                  },
                ),
                SizedBox(height: 20.h),
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
                      onChanged: (val) =>
                          context.read<VerificationCubit>().onCodeChanged(val),
                    );
                  },
                ),
                SizedBox(height: 28.h),
                BlocBuilder<VerificationCubit, VerificationState>(
                  buildWhen: (prev, curr) =>
                      prev.isLoading != curr.isLoading ||
                      prev.isValid != curr.isValid,
                  builder: (context, state) {
                    return AuthGradientButton(
                      text: widget.flow == VerifyFlow.registration
                          ? AppStrings.btnCreateAccount
                          : AppStrings.btnVerify,
                      isLoading: state.isLoading,
                      onPressed: state.isValid
                          ? () => context
                              .read<VerificationCubit>()
                              .verifyCode(_codeCtrl.text.trim())
                          : null,
                    );
                  },
                ),
                SizedBox(height: 22.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: BlocBuilder<VerificationCubit, VerificationState>(
                    buildWhen: (prev, curr) =>
                        prev.resendSeconds != curr.resendSeconds ||
                        prev.canResend != curr.canResend ||
                        prev.isResending != curr.isResending,
                    builder: (context, state) {
                      final cubit = context.read<VerificationCubit>();
                      final baseStyle = GoogleFonts.lato(
                        fontSize: 13.sp,
                        color: AppColors.authBottomText,
                      );
                      final linkStyle = GoogleFonts.lato(
                        fontSize: 13.sp,
                        color: AppColors.authBottomLink,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.authBottomLink,
                      );
                      final disabledStyle = GoogleFonts.lato(
                        fontSize: 13.sp,
                        color: AppColors.authBottomText.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500,
                      );
                      return SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 0,
                          runSpacing: 6.h,
                          children: [
                            Text(AppStrings.didntReceive, style: baseStyle),
                            if (!state.isResending && state.canResend)
                              Padding(
                                padding: EdgeInsets.only(left: 6.w),
                                child: GestureDetector(
                                  onTap: cubit.resendCode,
                                  child: Text(
                                    AppStrings.resendCode,
                                    style: linkStyle,
                                  ),
                                ),
                              )
                            else if (!state.isResending)
                              Padding(
                                padding: EdgeInsets.only(left: 6.w),
                                child: Text(
                                  '${AppStrings.resendCode} (${state.resendSeconds}s)',
                                  style: disabledStyle,
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
