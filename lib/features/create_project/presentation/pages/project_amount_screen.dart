import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/create_project_form.dart';
import '../cubit/create_project_cubit.dart';

/// Step 0: Goal amount entry with custom numpad.
class ProjectAmountScreen extends StatelessWidget {
  const ProjectAmountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final cubit = context.read<CreateProjectCubit>();
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // ── Top bar ─────────────────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          cubit.reset();
                          context.pop();
                        },
                        child: Icon(Icons.close_rounded,
                            size: 24.w, color: AppColors.textPrimary),
                      ),
                      Expanded(
                        child: Text(
                          AppStrings.projectAmountTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBody,
                          ),
                        ),
                      ),
                      // invisible placeholder to balance the close icon
                      SizedBox(width: 24.w),
                    ],
                  ),
                ),
              ),

              // ── Amount display ───────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.projectAmountSubtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      form.amountDigits.isEmpty ? '\$0.00' : form.formattedAmount,
                      style: GoogleFonts.inter(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: form.amountDigits.isEmpty
                              ? null
                              : () => context.push(AppRoutes.createProjectDetails),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.4),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.r)),
                          ),
                          child: Text(
                            AppStrings.btnContinue,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Numeric keypad ───────────────────────────────
              _AmountKeypad(
                onDigit: cubit.appendAmountDigit,
                onBackspace: cubit.removeAmountDigit,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AmountKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  const _AmountKeypad({required this.onDigit, required this.onBackspace});

  static const _keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.searchBarBg,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.4,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
        ),
        itemCount: _keys.length,
        itemBuilder: (_, i) {
          final k = _keys[i];
          if (k.isEmpty) return const SizedBox.shrink();
          return GestureDetector(
            onTap: () => k == '⌫' ? onBackspace() : onDigit(k),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Center(
                child: k == '⌫'
                    ? Icon(Icons.backspace_outlined,
                        size: 20.w, color: AppColors.textPrimary)
                    : Text(k,
                        style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
              ),
            ),
          );
        },
      ),
    );
  }
}
