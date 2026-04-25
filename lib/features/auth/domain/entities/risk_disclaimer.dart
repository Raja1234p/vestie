import 'package:equatable/equatable.dart';

class RiskDisclaimer extends Equatable {
  final String version;
  final List<String> guidelines;
  final bool accepted;

  const RiskDisclaimer({
    required this.version,
    required this.guidelines,
    required this.accepted,
  });

  @override
  List<Object?> get props => [version, guidelines, accepted];
}
