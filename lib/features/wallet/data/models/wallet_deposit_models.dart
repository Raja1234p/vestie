import 'package:vestie/core/utils/safe_parser.dart';

class WalletDepositIntentModel {
  final String clientSecret;
  final String paymentIntentId;
  final double? amount;
  /// Stripe PaymentIntent status from #6 (e.g. `requires_payment_method`, `succeeded`).
  final String? stripeStatus;
  final bool? requiresAction;

  const WalletDepositIntentModel({
    required this.clientSecret,
    required this.paymentIntentId,
    this.amount,
    this.stripeStatus,
    this.requiresAction,
  });

  /// Server charged the saved card on intent create — skip PaymentSheet.
  bool get paymentAlreadyComplete {
    final status = (stripeStatus ?? '').toLowerCase();
    if (status == 'succeeded') return true;
    if (status == 'processing' && requiresAction == false) return true;
    return false;
  }

  factory WalletDepositIntentModel.fromJson(Map<String, dynamic> json) {
    return WalletDepositIntentModel(
      clientSecret: json.safeString('clientSecret'),
      paymentIntentId: json.safeString(
        'paymentIntentId',
        defaultValue: json.safeString('paymentIntent'),
      ),
      amount: json.safeDoubleNullable('amount'),
      stripeStatus: json.safeStringNullable('status'),
      requiresAction: json['requiresAction'] is bool
          ? json['requiresAction'] as bool
          : null,
    );
  }
}

enum WalletDepositStatus {
  pending,
  completed,
  failed,
  cancelled,
  aborted,
  exhausted,
  unknown,
}

class WalletDepositStatusModel {
  final WalletDepositStatus status;
  final String? failureReason;

  const WalletDepositStatusModel({
    required this.status,
    this.failureReason,
  });

  factory WalletDepositStatusModel.fromJson(Map<String, dynamic> json) {
    final raw = json.safeString('status').toLowerCase();
    WalletDepositStatus mapped;
    switch (raw) {
      case 'completed':
      case 'succeeded':
        mapped = WalletDepositStatus.completed;
        break;
      case 'failed':
        mapped = WalletDepositStatus.failed;
        break;
      case 'cancelled':
      case 'canceled':
        mapped = WalletDepositStatus.cancelled;
        break;
      case 'aborted':
        mapped = WalletDepositStatus.aborted;
        break;
      case 'exhausted':
        mapped = WalletDepositStatus.exhausted;
        break;
      case 'pending':
      case 'processing':
        mapped = WalletDepositStatus.pending;
        break;
      default:
        mapped = WalletDepositStatus.unknown;
    }
    return WalletDepositStatusModel(
      status: mapped,
      failureReason: json.safeStringNullable('failureReason'),
    );
  }
}
