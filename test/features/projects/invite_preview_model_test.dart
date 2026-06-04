import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/projects/data/models/invite_preview_model.dart';

void main() {
  group('InvitePreviewModel.fromJson', () {
    test('parses description when backend sends key', () {
      final model = InvitePreviewModel.fromJson({
        'projectId': 'id-1',
        'projectName': 'Europe Trip',
        'projectType': 'vacation',
        'visibility': 'public',
        'requiresApproval': false,
        'expiresAtUtc': '2026-07-04T16:24:02+00:00',
        'isExpired': false,
        'isJoinable': true,
        'description': '  Save for summer  ',
      });

      expect(model.description, 'Save for summer');
    });

    test('description is null when key missing or empty', () {
      final withoutKey = InvitePreviewModel.fromJson(_baseJson());
      expect(withoutKey.description, isNull);

      final empty = InvitePreviewModel.fromJson({
        ..._baseJson(),
        'description': '   ',
      });
      expect(empty.description, isNull);
    });
  });
}

Map<String, dynamic> _baseJson() => {
      'projectId': 'id-1',
      'projectName': 'deep',
      'projectType': 'vacation',
      'visibility': 'public',
      'requiresApproval': false,
      'expiresAtUtc': '2026-07-04T16:24:02+00:00',
      'isExpired': false,
      'isJoinable': true,
    };
