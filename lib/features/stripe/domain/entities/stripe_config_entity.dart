import 'package:equatable/equatable.dart';

class StripeConfigEntity extends Equatable {
  final String publishableKey;
  final String connectAccountType;

  const StripeConfigEntity({
    required this.publishableKey,
    this.connectAccountType = 'express',
  });

  @override
  List<Object?> get props => [publishableKey, connectAccountType];
}
