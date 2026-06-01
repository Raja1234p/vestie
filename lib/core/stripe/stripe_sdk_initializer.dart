import 'package:flutter_stripe/flutter_stripe.dart';

import '../constants/stripe_constants.dart';

/// Initializes Stripe at app launch (required by flutter_stripe).
abstract final class StripeSdkInitializer {
  static Future<void> initialize() async {
    Stripe.publishableKey = StripeConstants.publishableKey;
    Stripe.urlScheme = StripeConstants.urlScheme;
    await Stripe.instance.applySettings();
  }

  /// Prefer API key when present; otherwise keep startup key.
  static Future<void> applyPublishableKey(String publishableKey) async {
    final key = publishableKey.trim();
    if (key.isEmpty) return;
    if (Stripe.publishableKey == key) return;

    Stripe.publishableKey = key;
    await Stripe.instance.applySettings();
  }
}
