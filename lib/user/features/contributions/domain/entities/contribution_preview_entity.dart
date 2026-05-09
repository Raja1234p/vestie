import 'package:equatable/equatable.dart';

class ContributionPreviewEntity extends Equatable {
  final double amount;
  final double platformFee;
  final double totalDeduction;
  final String currency;

  const ContributionPreviewEntity({
    required this.amount,
    required this.platformFee,
    required this.totalDeduction,
    required this.currency,
  });

  @override
  List<Object?> get props => [amount, platformFee, totalDeduction, currency];
}
