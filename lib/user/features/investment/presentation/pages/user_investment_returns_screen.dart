import 'package:flutter/material.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_returns/investment_returns_screen_host.dart';

/// Member “My Investment Returns” (Figma).
class UserInvestmentReturnsScreen extends StatelessWidget {
  final InvestmentReturnsRouteArgs args;

  const UserInvestmentReturnsScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return InvestmentReturnsScreenHost(
      args: args,
      title: AppStrings.userInvestmentReturnsTitle,
    );
  }
}
