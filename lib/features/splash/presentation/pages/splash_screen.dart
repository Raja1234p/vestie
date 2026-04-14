import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/widgets/layout/app_gradient_background.dart';
import '../bloc/splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Injecting the BLoC directly at the route level for scoped management
    return BlocProvider(
      create: (context) => SplashCubit()..initializeApp(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashCompleted) {
            if (state.isAuthenticated) {
              context.go(AppRoutes.dashboard);
            } else {
              context.go(AppRoutes.onboarding);
            }
          }
        },
        child: AppGradientBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo restricted by generic percentage / AppDimens to avoid absolute hardcoding
              SvgPicture.asset(
                AppAssets.logoSvg,
                width: 140.w,
                // SVG is natively white (fill="white") — no colorFilter needed
              ).padding(EdgeInsets.only(bottom: AppDimens.p16)),
            ],
          ).center(),
        ),
      ),
    );
  }
}
