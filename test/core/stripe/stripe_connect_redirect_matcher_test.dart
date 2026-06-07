import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/stripe/stripe_connect_redirect_matcher.dart';
import 'package:vestie/features/bank_accounts/presentation/constants/bank_flow_constants.dart';
import 'package:vestie/features/kyc/presentation/constants/kyc_flow_constants.dart';

void main() {
  group('vestie deep links', () {
    test('KYC complete', () {
      expect(KycFlowConstants.isCompletionUrl('vestie://kyc/complete'), isTrue);
      expect(
        StripeConnectRedirectMatcher.isVestieCompletion(
          Uri.parse('vestie://kyc/complete'),
          host: 'kyc',
        ),
        isTrue,
      );
    });

    test('KYC refresh with or without leading slash in path', () {
      expect(KycFlowConstants.isRefreshUrl('vestie://kyc/refresh'), isTrue);
      expect(
        StripeConnectRedirectMatcher.isVestieRefresh(
          Uri(scheme: 'vestie', host: 'kyc', path: 'refresh'),
          host: 'kyc',
        ),
        isTrue,
      );
    });

    test('Bank uses KYC HTTPS return paths for API', () {
      expect(BankFlowConstants.returnUrl, KycFlowConstants.returnUrl);
      expect(BankFlowConstants.refreshUrl, KycFlowConstants.refreshUrl);
      expect(BankFlowConstants.returnUrl, contains('/kyc/complete'));
    });

    test('Bank completion matches kyc and legacy bank deep links', () {
      expect(
        BankFlowConstants.isCompletionUrl('vestie://kyc/complete'),
        isTrue,
      );
      expect(BankFlowConstants.isCompletionUrl('vestie://bank/return'), isTrue);
      expect(BankFlowConstants.isRefreshUrl('vestie://kyc/refresh'), isTrue);
      expect(BankFlowConstants.isRefreshUrl('vestie://bank/refresh'), isTrue);
    });
  });
}
