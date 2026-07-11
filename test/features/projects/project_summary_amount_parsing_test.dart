import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/projects/data/models/project_summary_model.dart';

void main() {
  group('ProjectSummaryModel list amounts', () {
    Map<String, dynamic> _minimalJson(Map<String, dynamic> project) {
      return {
        'id': 'p1',
        'name': 'Test',
        'description': '',
        'type': 'investment',
        'visibility': 'public',
        'state': 'active',
        'createdUtc': '2026-07-01T12:00:00Z',
        'borrowingEnabled': false,
        'viewerRole': 'Member',
        'displayStatus': 'On Going',
        ...project,
      };
    }

    test('uses potAmount instead of raisedAmount when potAmount is present', () {
      final model = ProjectSummaryModel.fromJson(
        _minimalJson({
          'targetAmount': 5000,
          'raisedAmount': 10,
          'potAmount': 0,
          'totalContributed': 500,
        }),
      );

      expect(model.displayPotAmount, 0);
      expect(model.raisedDisplayAmount, 500);
    });

    test('falls back to raisedAmount when potAmount is omitted', () {
      final model = ProjectSummaryModel.fromJson(
        _minimalJson({
          'targetAmount': 5000,
          'raisedAmount': 250,
          'totalContributed': 500,
        }),
      );

      expect(model.displayPotAmount, 250);
      expect(model.raisedDisplayAmount, 250);
    });

    test('uses positive potAmount when provided', () {
      final model = ProjectSummaryModel.fromJson(
        _minimalJson({
          'targetAmount': 5000,
          'raisedAmount': 10,
          'potAmount': 300,
          'totalContributed': 500,
        }),
      );

      expect(model.raisedDisplayAmount, 300);
    });

    test('vacation list row falls back to totalContributed', () {
      final model = ProjectSummaryModel.fromJson(
        _minimalJson({
          'type': 'vacation',
          'targetAmount': 5000,
          'totalContributed': 500,
          'raisedAmount': 0,
          'potAmount': 0,
        }),
      );

      expect(model.raisedDisplayAmount, 500);
    });

    test('cancelled list row falls back to viewerRefundAmount', () {
      final model = ProjectSummaryModel.fromJson(
        _minimalJson({
          'type': 'vacation',
          'targetAmount': 5000,
          'raisedAmount': 0,
          'potAmount': 0,
          'totalContributed': 0,
          'viewerRefundAmount': 500,
          'displayStatus': 'Cancelled',
        }),
      );

      expect(model.raisedDisplayAmount, 500);
    });
  });
}
