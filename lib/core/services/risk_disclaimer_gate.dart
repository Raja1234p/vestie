import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/dashboard/domain/dashboard_prefetch.dart';

/// Ensures risk disclaimer is accepted before wallet / KYC / bank / withdraw APIs.
class RiskDisclaimerGate {
  RiskDisclaimerGate._();

  /// Guards against multiple tabs triggering the redirect in the same frame.
  static bool _recovering = false;

  static Future<bool> ensureAccepted(BuildContext context) async {
    final useCase = ServiceLocator.instance.getRiskDisclaimerUseCase;
    final result = await useCase();
    return result.fold((_) => true, (d) {
      if (d.accepted) return true;
      if (context.mounted) {
        context.push(AppRoutes.agreement);
      }
      return false;
    });
  }

  static bool isDisclaimerForbidden(Failure failure) =>
      failure is ForbiddenFailure;

  /// Recovers from a gated-API `403`: the server does not consider the disclaimer
  /// accepted (stale local cache / new version), so clear the local flag and route
  /// to the Agreement screen instead of showing a dead-end error.
  static Future<void> recoverFromForbidden(BuildContext context) async {
    if (_recovering) return;
    _recovering = true;

    DashboardPrefetch.riskDisclaimerAccepted = false;
    try {
      await ServiceLocator.instance.authRepository
          .clearRiskDisclaimerLocalCache();
    } catch (_) {}

    if (context.mounted) {
      context.go(AppRoutes.agreement);
    }

    // Allow the current build batch to settle before re-arming the guard.
    Future<void>.delayed(
      const Duration(milliseconds: 500),
      () => _recovering = false,
    );
  }
}
