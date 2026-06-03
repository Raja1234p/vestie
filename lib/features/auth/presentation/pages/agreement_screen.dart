import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_failure_dialog.dart';
import '../../../../core/widgets/common/app_tick_switch.dart';
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
    return BlocConsumer<AgreementCubit, AgreementState>(
      listener: (context, state) {
        if (state.isSuccess) {
          context.go(AppRoutes.dashboard);
        } else if (state.error != null) {
          AppFailureDialog.show(context, message: state.error!);
        }
      },
      builder: (context, state) {
        final accepted = state.isAccepted;
        final iconSide = 64.w;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),

                  // ── Agreement hero icon (design SVG) ──────────────────
                  Center(
                    child: SizedBox(
                      width: iconSide,
                      height: iconSide,
                      child: SvgPicture.asset(
                        AppAssets.agreementIcon,
                        width: iconSide,
                        height: iconSide,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ── Title ─────────────────────────────────────────────
                  Center(
                    child: Text(
                      AppStrings.agreementTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
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
                      style: GoogleFonts.lato(
                        fontSize: 13.sp,
                        color: AppColors.textBody,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ── Guidelines list (dashed frame + internal dividers) ─
                  if (state.isLoading && state.disclaimer == null)
                    const Center(child: CircularProgressIndicator())
                  else
                    _AgreementGuidelinesBox(
                      guidelines: state.disclaimer?.guidelines ??
                          AppStrings.agreementItems,
                    ),
                  SizedBox(height: 20.h),

                  // ── Agreement switch row ──────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppTickSwitch(
                        value: accepted,
                        onChanged: (_) => context.read<AgreementCubit>().toggle(),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          AppStrings.agreementCheckbox,
                          style: GoogleFonts.lato(
                            fontSize: 13.sp,
                            color: AppColors.textBody,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28.h),

                  // ── Continue button ───────────────────────────────────
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: (accepted && !state.isLoading) ? 1.0 : 0.45,
                    child: AppButton(
                      text: AppStrings.btnContinue,
                      isLoading: state.isLoading,
                      onPressed: (accepted && !state.isLoading)
                          ? () => context.read<AgreementCubit>().submit()
                          : null,
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Lavender dashed outer border (#DDD0FC) + dashed row separators.
class _AgreementGuidelinesBox extends StatelessWidget {
  const _AgreementGuidelinesBox({required this.guidelines});

  final List<String> guidelines;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: Radius.circular(12.r),
          color: AppColors.purple300,
          strokeWidth: 1,
          dashPattern: AppDimens.dottedBorderDashPattern,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < guidelines.length; i++) ...[
                if (i > 0) ...[
                  SizedBox(height: 12.h),
                  const _AgreementGuidelineDivider(),
                  SizedBox(height: 12.h),
                ],
                _GuidelineItem(number: i + 1, text: guidelines[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementGuidelineDivider extends StatelessWidget {
  const _AgreementGuidelineDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, 1),
          painter: _AgreementHorizontalDashPainter(color: AppColors.purple300),
        );
      },
    );
  }
}

class _AgreementHorizontalDashPainter extends CustomPainter {
  _AgreementHorizontalDashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    var startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GuidelineItem extends StatelessWidget {
  final int number;
  final String text;

  const _GuidelineItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number.',
          style: GoogleFonts.lato(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.authSubtitle,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              color: AppColors.textBody,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
