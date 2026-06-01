import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_failure_dialog.dart';
import 'package:vestie/core/widgets/common/app_loading_dialog.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';

/// Opens Stripe PaymentSheet (SetupIntent) in place — no Add Card screen.
abstract final class AddCardStripeLauncher {
  static Future<PaymentCard?> launch(
    BuildContext context, {
    bool showSuccessSnackBar = true,
  }) async {
    var preparingDialogOpen = false;

    void dismissPreparing() {
      if (!preparingDialogOpen || !context.mounted) return;
      preparingDialogOpen = false;
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    }

    try {
      if (context.mounted) {
        preparingDialogOpen = true;
        await AppLoadingDialog.show(
          context,
          message: AppStrings.loading,
        );
      }

      final result =
          await ServiceLocator.instance.savePaymentCardViaSetupUseCase(
        onBeforePresentPaymentSheet: () async {
          dismissPreparing();
          if (context.mounted) {
            await WidgetsBinding.instance.endOfFrame;
          }
        },
      );

      dismissPreparing();

      if (!context.mounted) return null;

      return result.fold(
        (failure) {
          final message = FailureMapper.userMessage(failure);
          if (message == AppStrings.addCardStripeCancelled) {
            return null;
          }
          AppFailureDialog.show(
            context,
            title: AppStrings.errorDialogTitle,
            message: message,
          );
          return null;
        },
        (card) {
          if (showSuccessSnackBar) {
            AppSnackBar.showSuccess(context, AppStrings.cardSavedSuccess);
          }
          return card;
        },
      );
    } catch (_) {
      dismissPreparing();
      if (context.mounted) {
        AppSnackBar.showError(context, AppStrings.addCardStripeFailed);
      }
      return null;
    }
  }
}
