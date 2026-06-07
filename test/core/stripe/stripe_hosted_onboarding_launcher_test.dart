import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/stripe/stripe_hosted_onboarding_launcher.dart';

void main() {
  group('StripeHostedOnboardingLauncher.isIos174OrNewer', () {
    test('returns true for iOS 17.4 and newer', () {
      expect(StripeHostedOnboardingLauncher.isIos174OrNewer('17.4'), isTrue);
      expect(StripeHostedOnboardingLauncher.isIos174OrNewer('18.2'), isTrue);
    });

    test('returns false for iOS below 17.4', () {
      expect(StripeHostedOnboardingLauncher.isIos174OrNewer('17.3.1'), isFalse);
      expect(StripeHostedOnboardingLauncher.isIos174OrNewer('16.0'), isFalse);
    });
  });
}
