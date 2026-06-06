import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/widgets/common/app_loader.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/kyc/presentation/kyc_browser_onboarding_runner.dart';
import 'package:vestie/features/kyc/presentation/models/kyc_onboarding_result.dart';

/// Opens Stripe KYC in the browser immediately (route entry only — no onboarding UI).
class KycOnboardingScreen extends StatefulWidget {
  const KycOnboardingScreen({super.key});

  @override
  State<KycOnboardingScreen> createState() => _KycOnboardingScreenState();
}

class _KycOnboardingScreenState extends State<KycOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    try {
      final result = await KycBrowserOnboardingRunner.run();
      if (!mounted) return;
      context.pop(result);
    } catch (_) {
      if (!mounted) return;
      context.pop(KycOnboardingResult.canceled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(child: Center(child: AppLoader())),
    );
  }
}
