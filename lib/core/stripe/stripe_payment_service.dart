import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../constants/app_strings.dart';
import '../constants/stripe_constants.dart';
import 'stripe_sdk_initializer.dart';

enum StripeDepositPaymentResult { completed, cancelled, failed }

enum StripeSetupPaymentResult { completed, cancelled, failed }

class StripeSetupPaymentOutcome {
  final StripeSetupPaymentResult result;
  final String? paymentMethodId;
  final String? errorMessage;

  const StripeSetupPaymentOutcome({
    required this.result,
    this.paymentMethodId,
    this.errorMessage,
  });
}

/// Default country when Stripe PaymentSheet opens (ISO 3166-1 alpha-2).
const BillingDetails _paymentSheetDefaultBillingDetails = BillingDetails(
  address: Address(
    city: null,
    country: 'US',
    line1: null,
    line2: null,
    postalCode: null,
    state: null,
  ),
);

/// PaymentSheet wrapper for deposits (PaymentIntent) and add card (SetupIntent).
class StripePaymentService {
  Future<void> ensureInitialized(String publishableKey) async {
    await StripeSdkInitializer.applyPublishableKey(publishableKey);
  }

  Future<StripeDepositPaymentResult> confirmDepositPayment({
    required String clientSecret,
  }) async {
    final secret = clientSecret.trim();
    if (secret.isEmpty) {
      return StripeDepositPaymentResult.failed;
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: secret,
          merchantDisplayName: AppStrings.appName,
          returnURL: StripeConstants.returnUrl,
          billingDetails: _paymentSheetDefaultBillingDetails,
        ),
      );
      await _presentPaymentSheet();
      return StripeDepositPaymentResult.completed;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return StripeDepositPaymentResult.cancelled;
      }
      return StripeDepositPaymentResult.failed;
    } catch (_) {
      return StripeDepositPaymentResult.failed;
    }
  }

  /// SetupIntent + PaymentSheet — card details go to Stripe, not Vestie API.
  Future<StripeSetupPaymentOutcome> confirmSetupPayment({
    required String clientSecret,
  }) async {
    final secret = clientSecret.trim();
    if (secret.isEmpty) {
      return const StripeSetupPaymentOutcome(
        result: StripeSetupPaymentResult.failed,
        errorMessage: AppStrings.addCardMissingClientSecret,
      );
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: secret,
          merchantDisplayName: AppStrings.appName,
          returnURL: StripeConstants.returnUrl,
          primaryButtonLabel: AppStrings.btnSaveCard,
          style: ThemeMode.system,
          billingDetails: _paymentSheetDefaultBillingDetails,
        ),
      );

      await _presentPaymentSheet();

      final setupIntent = await Stripe.instance.retrieveSetupIntent(secret);
      if (setupIntent.status.toLowerCase() != 'succeeded') {
        return StripeSetupPaymentOutcome(
          result: StripeSetupPaymentResult.failed,
          errorMessage: 'Card setup did not complete (${setupIntent.status}).',
        );
      }

      final paymentMethodId = setupIntent.paymentMethodId.trim();
      if (paymentMethodId.isEmpty) {
        return const StripeSetupPaymentOutcome(
          result: StripeSetupPaymentResult.failed,
          errorMessage: AppStrings.addCardStripeFailed,
        );
      }

      return StripeSetupPaymentOutcome(
        result: StripeSetupPaymentResult.completed,
        paymentMethodId: paymentMethodId,
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return const StripeSetupPaymentOutcome(
          result: StripeSetupPaymentResult.cancelled,
        );
      }
      final msg = e.error.localizedMessage?.trim() ?? e.error.message?.trim();
      return StripeSetupPaymentOutcome(
        result: StripeSetupPaymentResult.failed,
        errorMessage: msg != null && msg.isNotEmpty
            ? msg
            : AppStrings.addCardStripeFailed,
      );
    } catch (e) {
      return StripeSetupPaymentOutcome(
        result: StripeSetupPaymentResult.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _presentPaymentSheet() async {
    await SchedulerBinding.instance.endOfFrame;
    await Future<void>.delayed(Duration.zero);
    await Stripe.instance.presentPaymentSheet();
  }
}
