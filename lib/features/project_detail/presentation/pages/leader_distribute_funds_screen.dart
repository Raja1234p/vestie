import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_returns/investment_returns_screen_shell.dart';

/// Leader “Distribute Funds” — summary, history, and CTA (Figma).
class LeaderDistributeFundsScreen extends StatelessWidget {
  final InvestmentReturnsUiData data;

  const LeaderDistributeFundsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InvestmentReturnsScreenShell(
      title: AppStrings.btnDistributeFunds,
      data: data,
      footer: AppButton(
        text: AppStrings.btnDistributeFunds,
        onPressed: () => ProjectDetailNavigationHelpers.openDistributeFundsFlow(
          context,
          returnsData: data,
        ),
      ),
    );
  }
}
