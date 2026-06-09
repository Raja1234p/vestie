import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/user/features/borrow/data/mappers/borrow_repay_mapper.dart';
import 'package:vestie/user/features/borrow/data/models/borrow_repay_models.dart';

void main() {
  group('BorrowRepaySummaryModel', () {
    test('fromJson and mapper produce repayable summary', () {
      final model = BorrowRepaySummaryModel.fromJson({
        'borrowRequestId': 'req-1',
        'projectId': 'proj-1',
        'projectName': 'Europe 2025',
        'borrowAmount': 300,
        'borrowDate': '2026-05-24T00:00:00Z',
        'dueDate': '2026-06-01T00:00:00Z',
        'principalAmount': 300,
        'penaltyAmount': 45,
        'totalRepayment': 345,
        'status': 'Overdue',
        'canRepay': true,
      });

      final entity = BorrowRepayMapper.toSummaryEntity(model);
      expect(entity.borrowRequestId, 'req-1');
      expect(entity.canRepay, isTrue);
      expect(entity.totalRepayment, 345);
      expect(entity.penaltyPercent, 15);
      expect(entity.borrowDateLabel, isNotEmpty);
    });
  });

  group('BorrowRepayPaymentOptionsModel', () {
    test('mapper prefers wallet when sufficient and maps card brand', () {
      final model = BorrowRepayPaymentOptionsModel.fromJson({
        'borrowRequestId': 'req-1',
        'totalRepayment': 345,
        'currency': 'USD',
        'wallet': {
          'availableBalance': 500,
          'hasSufficientBalance': true,
          'balanceTone': 'positive',
        },
        'cards': [
          {
            'id': 'card-1',
            'brand': 'visa',
            'last4': '4242',
            'displayLabel': 'Visa •••• 4242',
            'isDefault': true,
          },
        ],
      });

      final entity = BorrowRepayMapper.toPaymentOptionsEntity(model);
      expect(entity.preferWallet, isTrue);
      expect(entity.preferredCardId, 'card-1');
      expect(entity.cards.first.brand.name, 'visa');
      expect(entity.cards.first.last4, '4242');
    });
  });

  group('BorrowRepayPreviewModel', () {
    test('fromJson maps penalty breakdown', () {
      final model = BorrowRepayPreviewModel.fromJson({
        'borrowRequestId': 'req-1',
        'projectId': 'proj-1',
        'projectName': 'Europe 2025',
        'repayAmount': 345,
        'currency': 'USD',
        'paymentSourceType': 'Card',
        'paymentMethodDisplay': 'Visa •••• 4242',
        'dueDate': '2026-06-01T00:00:00Z',
        'principalAmount': 300,
        'penalty': {
          'percentage': 15,
          'amount': 45,
          'display': '15% (\$45.00)',
        },
        'totalRepayment': 345,
      });

      final entity = BorrowRepayMapper.toPreviewEntity(model);
      expect(entity.paymentSourceType, 'Card');
      expect(entity.penaltyPercent, 15);
      expect(entity.totalRepayment, 345);
    });
  });
}
