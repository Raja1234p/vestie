import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';

/// Gradient + flow sub-header shell for member / co-leader cast-vote UI.
class SuccessVoteCastShell extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onBack;

  const SuccessVoteCastShell({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthFlowSubHeader(
              title: title,
              onBack:
                  onBack ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.dashboard);
                    }
                  },
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
