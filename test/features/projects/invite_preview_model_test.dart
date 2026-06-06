import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/projects/data/models/invite_preview_model.dart';

void main() {
  group('InvitePreviewModel.fromJson', () {
    test('parses current invite preview API shape', () {
      final model = InvitePreviewModel.fromJson({
        'projectId': '43b78933-d41a-4d26-95a3-226abaf05d94',
        'projectName': 'test today',
        'description': 'ggg',
        'projectType': 'vacation',
        'visibility': 'public',
        'memberCount': 2,
        'raisedAmount': 0,
        'roi': null,
        'requiresApproval': false,
        'expiresAtUtc': '2026-07-04T17:49:09+00:00',
        'isExpired': false,
        'isJoinable': true,
      });

      expect(model.projectName, 'test today');
      expect(model.description, 'ggg');
      expect(model.memberCount, 2);
      expect(model.raisedAmount, 0);
      expect(model.roiPercentage, isNull);
      expect(model.isJoinable, isTrue);
    });

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

    test('parses roi from roi key and normalizes non-positive to null', () {
      final withRoi = InvitePreviewModel.fromJson({..._baseJson(), 'roi': 4.5});
      expect(withRoi.roiPercentage, 4.5);

      final zeroRoi = InvitePreviewModel.fromJson({..._baseJson(), 'roi': 0});
      expect(zeroRoi.roiPercentage, isNull);
    });

    test('falls back to legacy roi and contribution keys', () {
      final model = InvitePreviewModel.fromJson({
        ..._baseJson(),
        'expectedRoi': 3,
        'contributionCount': 7,
      });

      expect(model.roiPercentage, 3);
      expect(model.contributionCount, 7);
      expect(model.raisedAmount, isNull);
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
