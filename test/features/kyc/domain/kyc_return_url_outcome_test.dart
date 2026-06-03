import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/kyc/domain/entities/kyc_status_entity.dart';
import 'package:vestie/features/kyc/domain/kyc_return_url_outcome.dart';

void main() {
  group('KycStatusEntity.returnUrlOutcome', () {
    test('withdrawReady when canWithdraw', () {
      const status = KycStatusEntity(
        status: KycStatus.verified,
        payoutsEnabled: true,
      );
      expect(status.returnUrlOutcome, KycReturnUrlOutcome.withdrawReady);
    });

    test('incomplete when requirements are due', () {
      const status = KycStatusEntity(
        status: KycStatus.pending,
        requirementsCurrentlyDue: ['individual.id_number'],
      );
      expect(status.returnUrlOutcome, KycReturnUrlOutcome.incomplete);
    });

    test('underReview when pending without requirements', () {
      const status = KycStatusEntity(status: KycStatus.pending);
      expect(status.returnUrlOutcome, KycReturnUrlOutcome.underReview);
    });

    test('rejected when status is rejected', () {
      const status = KycStatusEntity(status: KycStatus.rejected);
      expect(status.returnUrlOutcome, KycReturnUrlOutcome.rejected);
    });

    test('incomplete when not started after return', () {
      const status = KycStatusEntity(status: KycStatus.notStarted);
      expect(status.returnUrlOutcome, KycReturnUrlOutcome.incomplete);
    });
  });
}
