import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/services/project_invite_link_parser.dart';

void main() {
  group('parseProjectInviteCode', () {
    test('parses https vestie.app join path', () {
      final uri = Uri.parse('https://vestie.app/join/family-vacation-2025');
      expect(parseProjectInviteCode(uri), 'family-vacation-2025');
    });

    test('parses vestie scheme join host', () {
      final uri = Uri.parse('vestie://join/summer-squad');
      expect(parseProjectInviteCode(uri), 'summer-squad');
    });

    test('returns null for unrelated urls', () {
      expect(
        parseProjectInviteCode(Uri.parse('https://vestie.app/dashboard')),
        isNull,
      );
    });
  });
}
