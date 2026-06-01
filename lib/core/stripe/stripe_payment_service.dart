import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:vestie/core/constants/app_strings.dart';

enum StripeDepositPaymentResult {
  completed,
  cancelled,
  failed,
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
}
