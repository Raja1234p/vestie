import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/invites/presentation/constants/invite_flow_constants.dart';

void main() {
  group('InviteFlowConstants.isInviteDeepLink', () {
    test('accepts vestie join', () {
      expect(
        InviteFlowConstants.isInviteDeepLink(
          Uri.parse('vestie://join/L6NM4L8BWF'),
        ),
        isTrue,
      );
    });

    test('accepts https join on azure', () {
      expect(
        InviteFlowConstants.isInviteDeepLink(
          Uri.parse(
            'https://vestie-backend-prod-hsaghpaedggzhhh9.centralus-01.azurewebsites.net/join/ABC',
          ),
        ),
        isTrue,
      );
    });

    test('rejects kyc complete callback', () {
      expect(
        InviteFlowConstants.isInviteDeepLink(
          Uri.parse('vestie://kyc/complete'),
        ),
        isFalse,
      );
    });
  });
}
