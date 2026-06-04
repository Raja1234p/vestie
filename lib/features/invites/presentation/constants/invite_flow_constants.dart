import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/services/project_invite_link_parser.dart';
import 'package:vestie/core/stripe/stripe_connect_redirect_matcher.dart';

/// Deep links for shared project invites (parity with [KycFlowConstants]).
final class InviteFlowConstants {
  InviteFlowConstants._();

  static const String appSchemeJoinHost = 'join';

  static String appSchemeJoinUrl(String inviteCode) =>
      'vestie://$appSchemeJoinHost/${inviteCode.trim()}';

  static String httpsShareUrl(String inviteCode) =>
      ApiConstants.inviteShareUrl(inviteCode);

  /// True when [uri] is an invite link and not a Stripe KYC/bank callback.
  static bool isInviteDeepLink(Uri uri) {
    if (parseProjectInviteCode(uri) == null) return false;
    return !_isStripeConnectCallback(uri);
  }

  static bool _isStripeConnectCallback(Uri uri) {
    if (uri.scheme != 'vestie') return false;
    return StripeConnectRedirectMatcher.isVestieCompletion(uri, host: 'kyc') ||
        StripeConnectRedirectMatcher.isVestieRefresh(uri, host: 'kyc') ||
        StripeConnectRedirectMatcher.isVestieCompletion(uri, host: 'bank') ||
        StripeConnectRedirectMatcher.isVestieRefresh(uri, host: 'bank');
  }
}
