import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Typed [BuildContext] navigation helpers. All paths use [AppRoutes] — never
/// raw strings.
extension VestieRouteExtensions on BuildContext {
  void goToSplash() => go(AppRoutes.splash);

  void goToLogin() => go(AppRoutes.login);

  void goToDashboard() => go(AppRoutes.dashboard);

  void goToAgreement() => go(AppRoutes.agreement);

  void goToNotifications() => go(AppRoutes.notifications);

  void goToVffHub() => go(AppRoutes.userVffMain);

  void pushProjectDetail({required Object extra}) =>
      push(AppRoutes.projectDetail, extra: extra);

  void pushContributeFlow({required Object extra}) =>
      push(AppRoutes.contributeFlow, extra: extra);

  void pushWalletTransactionAmount({required Object extra}) =>
      push(AppRoutes.transactionAmount, extra: extra);
}
