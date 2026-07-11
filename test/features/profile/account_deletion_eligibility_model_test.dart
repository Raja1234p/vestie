import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/features/profile/data/models/account_deletion_eligibility_model.dart';

void main() {
  group('AccountDeletionEligibilityModel', () {
    test('parses eligible response with API eligible key', () {
      final model = AccountDeletionEligibilityModel.fromJson({
        'eligible': true,
        'reasons': <String>[],
      });

      expect(model.isEligible, isTrue);
      expect(model.reasons, isEmpty);
      expect(model.toEntity().isEligible, isTrue);
    });

    test('parses ineligible API shape with backend reasons array', () {
      final model = AccountDeletionEligibilityModel.fromJson({
        'eligible': false,
        'reasons': [
          'You have an active borrow.',
          'You are leading an active project.',
        ],
      });

      expect(model.isEligible, isFalse);
      expect(model.reasons, [
        'You have an active borrow.',
        'You are leading an active project.',
      ]);
      expect(
        model.toEntity().displayIneligibilityMessage,
        'You have an active borrow.\nYou are leading an active project.',
      );
    });

    test('parses human-readable reason string when provided', () {
      final model = AccountDeletionEligibilityModel.fromJson({
        'eligible': false,
        'reason': 'Active wallet balance must be withdrawn first.',
      });

      expect(model.isEligible, isFalse);
      expect(model.reasons, ['Active wallet balance must be withdrawn first.']);
    });

    test('returns empty reasons when ineligible with empty reasons array', () {
      final model = AccountDeletionEligibilityModel.fromJson({
        'eligible': false,
        'reasons': <String>[],
      });

      expect(model.isEligible, isFalse);
      expect(model.reasons, isEmpty);
      expect(model.toEntity().displayIneligibilityMessage, isEmpty);
    });
  });
}
