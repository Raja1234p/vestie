import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_success_screen.dart';

class ContributionSuccessScreen extends StatelessWidget {
  const ContributionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSuccessScreen(
      backgroundImagePath: AppAssets.contributionSuccessBg,
      title: AppStrings.contributionSuccessTitle,
      buttonText: AppStrings.btnBackToWallet,
      onButtonPressed: () {
        context.go(AppRoutes.dashboard);
      },
    );
  }
}
