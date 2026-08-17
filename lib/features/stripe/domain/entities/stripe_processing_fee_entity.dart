import 'package:equatable/equatable.dart';

class StripeProcessingFeeEntity extends Equatable {
  const StripeProcessingFeeEntity({
    required this.stripeFeeCents,
    required this.stripeFee,
    required this.isEstimated,
    required this.depositAmount,
    required this.netAmount,
    this.paymentIntentId,
    this.status,
  });

  final int stripeFeeCents;
  final double stripeFee;
  final bool isEstimated;
  final double depositAmount;
  final double netAmount;
  final String? paymentIntentId;
  final String? status;

  double get netCredit => netAmount;

  @override
  List<Object?> get props => [
        stripeFeeCents,
        stripeFee,
        isEstimated,
        depositAmount,
        netAmount,
        paymentIntentId,
        status,
      ];
}
