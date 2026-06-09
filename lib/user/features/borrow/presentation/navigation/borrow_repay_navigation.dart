import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/borrow_repay_flow_args.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/user/features/borrow/domain/entities/borrow_repay_entities.dart';
import 'package:vestie/user/features/borrow/presentation/mappers/borrow_repay_confirm_route_args_mapper.dart';

/// Payment options → confirm repay → success (Week 8 API).
///
/// Uses [ServiceLocator] for use cases (acceptable for navigation glue; inject
/// dependencies when adding widget/navigation tests).
class BorrowRepayNavigation {
  BorrowRepayNavigation._();

  static Future<void> openPaymentOptions(
    BuildContext context,
    BorrowRepayPaymentOptionsRouteArgs args,
  ) {
    return context.push(AppRoutes.borrowRepayPaymentOptions, extra: args);
  }

  /// Loads repay options once; auto-skips picker when wallet or default card applies.
  static Future<void> startRepayFlow(
    BuildContext context,
    BorrowRepayPaymentOptionsRouteArgs args,
  ) async {
    final sl = ServiceLocator.instance;
    final optionsResult = await sl.getBorrowRepayPaymentOptionsUseCase(
      projectId: args.projectId,
      borrowRequestId: args.borrowRequestId,
    );
    if (!context.mounted) return;

    await optionsResult.fold(
      (failure) async {
        AppToast.showError(context, FailureMapper.userMessage(failure));
      },
      (options) async {
        if (options.preferWallet) {
          await _openConfirmWithPreview(
            context,
            args: args,
            options: options,
            paymentSourceType: 'Wallet',
          );
          return;
        }

        final cardId = options.preferredCardId;
        if (cardId != null) {
          await _openConfirmWithPreview(
            context,
            args: args,
            options: options,
            paymentSourceType: 'Card',
            paymentMethodId: cardId,
          );
          return;
        }

        await context.push(
          AppRoutes.borrowRepayPaymentOptions,
          extra: args.copyWith(preloadedOptions: options),
        );
      },
    );
  }

  static Future<void> _openConfirmWithPreview(
    BuildContext context, {
    required BorrowRepayPaymentOptionsRouteArgs args,
    required BorrowRepayPaymentOptionsEntity options,
    required String paymentSourceType,
    String? paymentMethodId,
  }) async {
    final previewResult = await ServiceLocator.instance
        .getBorrowRepayPreviewUseCase(
          projectId: args.projectId,
          borrowRequestId: args.borrowRequestId,
          paymentSourceType: paymentSourceType,
          paymentMethodId: paymentMethodId,
        );
    if (!context.mounted) return;

    await previewResult.fold(
      (failure) async {
        AppToast.showError(context, FailureMapper.userMessage(failure));
      },
      (preview) async {
        await context.push(
          AppRoutes.borrowRepayConfirm,
          extra: BorrowRepayConfirmRouteArgsMapper.fromPreview(
            preview: preview,
            fallbackProjectName: args.projectName,
            paymentSourceType: paymentSourceType,
            paymentMethodId: paymentMethodId,
          ),
        );
      },
    );
  }

  /// Closes the repay sub-flow (success → payment options → my borrow) and
  /// returns `true` to project detail so it can reload pot + borrow list.
  static void finishRepayFlow(BuildContext context) {
    if (!context.mounted) return;

    final router = GoRouter.of(context);
    while (context.canPop()) {
      final location = router.state.matchedLocation;
      final onRepayRoute =
          location == AppRoutes.borrowRepaySuccess ||
          location == AppRoutes.borrowRepayConfirm ||
          location == AppRoutes.borrowRepayPaymentOptions;
      if (!onRepayRoute) break;
      context.pop();
    }

    if (!context.mounted || !context.canPop()) return;
    context.pop(true);
  }
}
