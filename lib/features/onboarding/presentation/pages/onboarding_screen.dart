import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../bloc/onboarding_cubit.dart';
import '../widgets/onboarding_page_indicator.dart';

/// Figma-accurate Onboarding Screen.
///
/// Background : App-wide light lavender gradient (#CEBEFB → #F8F7FA).
/// Layout (top → bottom):
///   1. Page indicators (dark purple pills) — top of SafeArea
///   2. Medium-purple circle containing the illustration (PageView)
///   3. Title — bold dark, animated on page change
///   4. Spacer
///   5. Continue / Get Started button (solid primary-purple pill, white text)
///   6. Skip text link — dark, hidden on last page
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onContinue(BuildContext context, OnboardingCubit cubit) {
    if (cubit.isLastPage) {
      context.go(AppRoutes.login);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Scaffold(
        body:  SafeArea(
          child: BlocBuilder<OnboardingCubit, int>(
            builder: (context, currentIndex) {
              final cubit = context.read<OnboardingCubit>();
              final page = OnboardingCubit.pages[currentIndex];
          
              return Column(
                children: [
                  // ── Page Indicators ─────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(top: 30.h),
                    child: OnboardingPageIndicator(
                      pageCount: cubit.pageCount,
                      currentIndex: currentIndex,
                    ),
                  ),
          
                  // ── Illustration in medium-purple circle ─────────────
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.w, vertical: 24.h),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.onboardingCircleBg,
                            shape: BoxShape.circle,
                          ),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: OnboardingCubit.pages.length,
                            onPageChanged: cubit.goToPage,
                            itemBuilder: (_, index) {
                              return Padding(
                                padding: EdgeInsets.all(28.r),
                                child: Image.asset(
                                  OnboardingCubit.pages[index].imagePath,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
          
                  // ── Title ────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: Text(
                        page.title,
                        key: ValueKey(page.title),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onboardingTitle, // dark
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
          
                  const Spacer(),
          
                  // ── Continue / Get Started button ────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: AppButton(
                      text: cubit.isLastPage
                          ? AppStrings.onboardingGetStarted
                          : AppStrings.onboardingContinue,
                      onPressed: () => _onContinue(context, cubit),
                    ),
                  ),
                  SizedBox(height: 12.h),
          
                  // ── Skip ─────────────────────────────────────────────
                  if (!cubit.isLastPage)
                    TextButton(
                      onPressed: () {
                        cubit.skip();
                        _pageController.animateToPage(
                          OnboardingCubit.pages.length - 1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 4.h),
                        minimumSize: Size(0, 36.h),
                      ),
                      child: Text(
                        AppStrings.onboardingSkip,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onboardingSubtitle, // dark
                        ),
                      ),
                    )
                  else
                    SizedBox(height: 36.h),
          
                  SizedBox(height: 20.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
