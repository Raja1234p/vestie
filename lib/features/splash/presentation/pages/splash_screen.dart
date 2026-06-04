import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/storage/pending_project_invite_store.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../bloc/splash_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _didPrecache = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    _didPrecache = true;
    // Warm up the splash bitmap to avoid visible decode jank on first paint.
    precacheImage(const AssetImage(AppAssets.splashBackground), context);
  }

  @override
  Widget build(BuildContext context) {
    // Injecting the BLoC directly at the route level for scoped management
    return BlocProvider(
      create: (context) => SplashCubit()..initializeApp(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) async {
          if (state is! SplashCompleted) return;

          if (state.isAuthenticated) {
            if (!state.isDisclaimerAccepted) {
              context.go(AppRoutes.agreement);
              return;
            }

            final pendingInvite = await PendingProjectInviteStore.read();
            if (!context.mounted) return;

            if (pendingInvite != null && pendingInvite.isNotEmpty) {
              context.go(AppRoutes.projectInvitation(pendingInvite));
              return;
            }

            context.go(AppRoutes.dashboard);
          } else if (state.hasSeenOnboarding) {
            context.go(AppRoutes.login);
          } else {
            context.go(AppRoutes.onboarding);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.splashBackground,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SVG is natively white (fill="white"), so no color filter needed.
                SvgPicture.asset(
                  AppAssets.logoSvg,
                  width: 200.w,
                ).padding(EdgeInsets.only(bottom: AppDimens.p16)),
              ],
            ).center(),
          ],
        ),
      ),
    );
  }
}
