import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failures.dart';

/// Ensures risk disclaimer is accepted before wallet / KYC / bank / withdraw APIs.
class RiskDisclaimerGate {
  RiskDisclaimerGate._();

  static Future<bool> ensureAccepted(BuildContext context) async {
    final useCase = ServiceLocator.instance.getRiskDisclaimerUseCase;
    final result = await useCase();
    return result.fold(
      (_) => true,
      (d) {
        if (d.accepted) return true;
        if (context.mounted) {
          context.push(AppRoutes.agreement);
        }
        return false;
      },
    );
  }

  static bool isDisclaimerForbidden(Failure failure) =>
      failure is ForbiddenFailure;
}
