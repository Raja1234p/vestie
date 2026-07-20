import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/utils/invite_share_link_resolver.dart';

void main() {
  group('resolveInviteShareLink', () {
    test('builds azure url from bare code', () {
      expect(
        resolveInviteShareLink('L6NM4L8BWF'),
        'https://vestie-backend-prod-hsaghpaedggzhhh9.centralus-01.azurewebsites.net/join/L6NM4L8BWF',
      );
    });

    test('passes through full https url', () {
      const url =
          'https://vestie-backend-prod-hsaghpaedggzhhh9.centralus-01.azurewebsites.net/join/ABC';
      expect(resolveInviteShareLink(url), url);
    });

    test('converts vestie scheme to https share url', () {
      expect(
        resolveInviteShareLink('vestie://join/L6NM4L8BWF'),
        contains('/join/L6NM4L8BWF'),
      );
    });
  });
}
