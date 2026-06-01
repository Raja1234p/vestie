import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:vestie/core/constants/app_strings.dart';

enum StripeDepositPaymentResult {
  completed,
  cancelled,
  failed,
}

enum StripeSetupPaymentResult {
  completed,
  cancelled,
  failed,
}

class StripeSetupPaymentOutcome {
  final StripeSetupPaymentResult result;
  final String? paymentMethodId;

  const StripeSetupPaymentOutcome({
    required this.result,
    this.paymentMethodId,
  });
}

/// Stripe SDK wrapper for wallet deposit (PaymentIntent + PaymentSheet).
class StripePaymentService {
  String? _publishableKey;

  Future<void> ensureInitialized(String publishableKey) async {
    final key = publishableKey.trim();
    if (key.isEmpty) {
      throw StateError('Stripe publishable key is missing');
    }
    if (_publishableKey == key) return;

    Stripe.publishableKey = key;
    await Stripe.instance.applySettings();
    _publishableKey = key;
  }

  /// Presents PaymentSheet for a deposit PaymentIntent [clientSecret].
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
        ),
      );
      await Stripe.instance.presentPaymentSheet();
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

  /// Presents PaymentSheet for a SetupIntent [clientSecret] (add card).
  Future<StripeSetupPaymentOutcome> confirmSetupPayment({
    required String clientSecret,
  }) async {
    final secret = clientSecret.trim();
    if (secret.isEmpty) {
      return const StripeSetupPaymentOutcome(result: StripeSetupPaymentResult.failed);
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: secret,
          merchantDisplayName: AppStrings.appName,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      final setupIntent = await Stripe.instance.retrieveSetupIntent(secret);
      final paymentMethodId = setupIntent.paymentMethodId.trim();
      if (paymentMethodId.isEmpty) {
        return const StripeSetupPaymentOutcome(
          result: StripeSetupPaymentResult.failed,
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
      return const StripeSetupPaymentOutcome(result: StripeSetupPaymentResult.failed);
    } catch (_) {
      return const StripeSetupPaymentOutcome(result: StripeSetupPaymentResult.failed);
    }
  }
}
