import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

import 'investment_returns_screen_body.dart';

/// Gradient shell + header + scroll body + optional pinned footer (Figma).
class InvestmentReturnsScreenShell extends StatelessWidget {
  final String title;
  final InvestmentReturnsUiData data;
  final Widget? footer;
  final ScrollController? scrollController;
  final Widget? listFooter;

  const InvestmentReturnsScreenShell({
    super.key,
    required this.title,
    required this.data,
    this.footer,
    this.scrollController,
    this.listFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: title,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: InvestmentReturnsScreenBody(
                data: data,
                hasPinnedFooter: footer != null,
                scrollController: scrollController,
                listFooter: listFooter,
              ),
            ),
            if (footer != null) FlowScreenFooter(child: footer!),
          ],
        ),
      ),
    );
  }
}
