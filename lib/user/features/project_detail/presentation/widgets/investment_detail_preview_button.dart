import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_preview_link.dart';

/// Dev/preview control on live investment detail (mirrors success-vote preview).
class InvestmentDetailPreviewButton extends StatelessWidget {
  final VoidCallback onPressed;

  const InvestmentDetailPreviewButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ProjectDetailPreviewLink(
      label: AppStrings.btnPreviewCompletedInvestment,
      onPressed: onPressed,
    );
  }
}
