import 'package:flutter/material.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_returns/investment_returns_screen_host.dart';

/// Leader “Distribute Funds” — summary, history, and CTA (Figma).
class LeaderDistributeFundsScreen extends StatelessWidget {
  final InvestmentReturnsRouteArgs args;

  const LeaderDistributeFundsScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return InvestmentReturnsScreenHost(
      args: args,
      title: AppStrings.btnDistributeFunds,
      footerBuilder: (ctx, data) => AppButton(
        text: AppStrings.btnDistributeFunds,
        onPressed: () => ProjectDetailNavigation.openDistributeFundsFlow(
          ctx,
          returnsData: data,
        ),
      ),
    );
  }
}
