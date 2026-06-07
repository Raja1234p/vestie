import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/api_constants.dart';
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

    test('Bank return and refresh', () {
      expect(BankFlowConstants.isCompletionUrl('vestie://bank/return'), isTrue);
      expect(BankFlowConstants.isRefreshUrl('vestie://bank/refresh'), isTrue);
    });

    test('Bank HTTPS under AASA stripe/onboarding path', () {
      expect(BankFlowConstants.isCompletionUrl(BankFlowConstants.returnUrl), isTrue);
      expect(BankFlowConstants.isRefreshUrl(BankFlowConstants.refreshUrl), isTrue);
      expect(
        BankFlowConstants.returnUrl,
        contains('/stripe/onboarding/bank/return'),
      );
    });

    test('Bank legacy HTTPS paths still match', () {
      expect(
        BankFlowConstants.isCompletionUrl(ApiConstants.legacyBankReturnUrl),
        isTrue,
      );
      expect(
        BankFlowConstants.isRefreshUrl(ApiConstants.legacyBankRefreshUrl),
        isTrue,
      );
    });
  });
}
