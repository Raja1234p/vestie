import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/features/stripe/data/models/stripe_processing_fee_model.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'package:vestie/features/wallet/domain/wallet_transaction_type.dart';

/// Sample bodies matching `GET /stripe/processing-fee`.
///
/// Confirm step: `?amount=<depositUsd>` → `isEstimated: true`
/// After pay: `?paymentIntentId=pi_...` → actual Stripe `balance_transaction.fee`
///
/// These fixtures follow typical US card pricing (≈ 2.9% + $0.30) so you can
/// see fee vs net vs new wallet balance. The app never computes that formula;
/// it only displays whatever the API returns.
class _FeeCase {
  const _FeeCase({
    required this.depositAmount,
    required this.stripeFeeCents,
    required this.query,
    required this.isEstimated,
    this.paymentIntentId,
    this.walletBalance = 50,
  });

  final double depositAmount;
  final int stripeFeeCents;
  final String query;
  final bool isEstimated;
  final String? paymentIntentId;
  final double walletBalance;

  double get stripeFee => stripeFeeCents / 100.0;
  double get netAmount =>
      double.parse((depositAmount - stripeFee).toStringAsFixed(2));
  double get newBalance =>
      double.parse((walletBalance + netAmount).toStringAsFixed(2));

  Map<String, dynamic> get apiJson => {
        'stripeFeeCents': stripeFeeCents,
        'stripeFee': stripeFee,
        'isEstimated': isEstimated,
        'depositAmount': depositAmount,
        'netAmount': netAmount,
        if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
        if (!isEstimated) 'status': 'succeeded',
      };
}

const _confirmCases = <_FeeCase>[
  _FeeCase(
    depositAmount: 10,
    stripeFeeCents: 59,
    query: 'GET /stripe/processing-fee?amount=10',
    isEstimated: true,
  ),
  _FeeCase(
    depositAmount: 25,
    stripeFeeCents: 103,
    query: 'GET /stripe/processing-fee?amount=25',
    isEstimated: true,
  ),
  _FeeCase(
    depositAmount: 50,
    stripeFeeCents: 175,
    query: 'GET /stripe/processing-fee?amount=50',
    isEstimated: true,
  ),
  _FeeCase(
    depositAmount: 100,
    stripeFeeCents: 320,
    query: 'GET /stripe/processing-fee?amount=100',
    isEstimated: true,
  ),
  _FeeCase(
    depositAmount: 250,
    stripeFeeCents: 755,
    query: 'GET /stripe/processing-fee?amount=250',
    isEstimated: true,
  ),
  _FeeCase(
    depositAmount: 1000,
    stripeFeeCents: 2930,
    query: 'GET /stripe/processing-fee?amount=1000',
    isEstimated: true,
  ),
];

const _actualAfterPay = _FeeCase(
  depositAmount: 100,
  stripeFeeCents: 321,
  query: 'GET /stripe/processing-fee?paymentIntentId=pi_abc123',
  isEstimated: false,
  paymentIntentId: 'pi_abc123',
);

void main() {
  group('deposit processing fee — different amounts', () {
    test('prints API query, fee, net credit, and new balance for each amount', () {
      const currentWallet = 50.0;
      // ignore: avoid_print
      print('\nConfirm Deposit (estimated) — wallet starts at '
          '${AppFormatters.formatCurrency(currentWallet)}');
      // ignore: avoid_print
      print('query | deposit | stripeFeeCents | fee shown | net to wallet | '
          'new balance | success copy');
      for (final c in _confirmCases) {
        final fee = StripeProcessingFeeModel.fromJson(c.apiJson);
        final line =
            '${c.query} | ${AppFormatters.formatCurrency(c.depositAmount)} | '
            '${c.stripeFeeCents}¢ | ${AppFormatters.formatCurrency(fee.stripeFee)} '
            '(Estimated) | ${AppFormatters.formatCurrency(fee.netAmount)} | '
            '${AppFormatters.formatCurrency(currentWallet + fee.netAmount)} | '
            '${AppFormatters.formatCurrency(fee.netAmount)} credited';
        // ignore: avoid_print
        print(line);
      }
      final actual = StripeProcessingFeeModel.fromJson(_actualAfterPay.apiJson);
      // ignore: avoid_print
      print('\nAfter Confirm (actual Stripe fee)');
      // ignore: avoid_print
      print('${_actualAfterPay.query} → fee '
          '${AppFormatters.formatCurrency(actual.stripeFee)} '
          '(not Estimated), success amount '
          '${AppFormatters.formatCurrency(actual.netAmount)}');
    });

    for (final c in _confirmCases) {
      test(
        '${c.query} → fee ${c.stripeFeeCents}¢, '
        'net ${c.netAmount}, new balance ${c.newBalance}',
        () {
          final fee = StripeProcessingFeeModel.fromJson({
            'value': c.apiJson,
          });

          expect(fee.depositAmount, c.depositAmount);
          expect(fee.stripeFeeCents, c.stripeFeeCents);
          expect(fee.stripeFee, closeTo(c.stripeFee, 0.001));
          expect(fee.netAmount, closeTo(c.netAmount, 0.001));
          expect(fee.isEstimated, isTrue);
          expect(
            fee.depositAmount - fee.stripeFee,
            closeTo(fee.netAmount, 0.011),
          );

          final newBalance = c.walletBalance + fee.netAmount;
          expect(newBalance, closeTo(c.newBalance, 0.001));

          final tx = WalletTransactionState(
            transactionType: WalletTransactionType.deposit,
            depositProcessingFee: fee,
          );
          expect(
            tx.formattedDepositNetCredit,
            AppFormatters.formatCurrency(fee.netAmount),
          );
        },
      );
    }

    test('after payment, actual cents replace estimate on success', () {
      final estimate = StripeProcessingFeeModel.fromJson(
        _confirmCases.firstWhere((c) => c.depositAmount == 100).apiJson,
      );
      final actual =
          StripeProcessingFeeModel.fromJson(_actualAfterPay.apiJson);

      expect(estimate.isEstimated, isTrue);
      expect(estimate.stripeFee, 3.20);
      expect(estimate.netAmount, 96.80);

      expect(actual.isEstimated, isFalse);
      expect(actual.paymentIntentId, 'pi_abc123');
      expect(actual.stripeFeeCents, 321);
      expect(actual.stripeFee, 3.21);
      expect(actual.netAmount, 96.79);
      expect(actual.status, 'succeeded');

      final success = WalletTransactionState(
        transactionType: WalletTransactionType.deposit,
        depositProcessingFee: actual,
      );
      expect(success.formattedDepositNetCredit, r'$96.79');
    });
  });
}
