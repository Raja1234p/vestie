import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../cubit/agreement_cubit.dart';

/// Shown to every new user after OTP verification.
/// Flow: Register → Verify → Agreement → Dashboard.
class AgreementScreen extends StatelessWidget {
  const AgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AgreementCubit(),
      child: const _AgreementBody(),
    );
  }
}

class _AgreementBody extends StatelessWidget {
  const _AgreementBody();

  @override
  Widget build(BuildContext context) {
    final accepted = context.watch<AgreementCubit>().state;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),

              // ── Warning icon ──────────────────────────────────────
              Center(
                child: Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 34.w,
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // ── Title ─────────────────────────────────────────────
              Center(
                child: Text(
                  AppStrings.agreementTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // ── Subtitle ──────────────────────────────────────────
              Center(
                child: Text(
                  AppStrings.agreementSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.textBody,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // ── Guidelines list ───────────────────────────────────
              ...AppStrings.agreementItems.asMap().entries.map(
                (e) => _GuidelineItem(number: e.key + 1, text: e.value),
              ),
              SizedBox(height: 20.h),

              // ── Checkbox row ──────────────────────────────────────
              GestureDetector(
                onTap: () => context.read<AgreementCubit>().toggle(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: accepted ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color: accepted ? AppColors.primary : const Color(0xFFCCCCDD),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: accepted
                          ? Icon(Icons.check, color: Colors.white, size: 14.w)
                          : null,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        AppStrings.agreementCheckbox,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.textBody,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),

              // ── Continue button ───────────────────────────────────
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: accepted ? 1.0 : 0.45,
                child: AppButton(
                  text: AppStrings.btnContinue,
                  onPressed: accepted
                      ? () => context.go(AppRoutes.dashboard)
                      : null,
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final int number;
  final String text;

  const _GuidelineItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number.',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textBody,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
