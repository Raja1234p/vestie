import 'package:flutter/material.dart';
import '../../../../core/widgets/common/app_numpad.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
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
                          style: GoogleFonts.lato(
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
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      form.amountDigits.isEmpty ? '\$0.00' : form.formattedAmount,
                      style: GoogleFonts.lato(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: AppButton(
                        text: AppStrings.btnContinue,
                        height: 50.h,
                        onPressed: form.amountDigits.isEmpty
                            ? null
                            : () => context.push(AppRoutes.createProjectDetails),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Numeric keypad ───────────────────────────────
              AppNumpad(
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

