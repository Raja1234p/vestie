import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_returns/investment_returns_screen_shell.dart';

/// Member “My Investment Returns” (Figma).
class UserInvestmentReturnsScreen extends StatelessWidget {
  final InvestmentReturnsUiData data;

  const UserInvestmentReturnsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return InvestmentReturnsScreenShell(
      title: AppStrings.userInvestmentReturnsTitle,
      data: data,
    );
  }
}
