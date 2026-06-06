import 'package:equatable/equatable.dart';

/// Successful POST /projects payload (API uses int enums for type, visibility, state).
class CreatedProjectEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final int type;
  final int visibility;
  final int state;
  final double targetAmount;
  final DateTime endsAtUtc;
  final DateTime? launchedAtUtc;
  final bool borrowingEnabled;
  final double? suggestedContributionAmount;
  final DateTime createdUtc;

  const CreatedProjectEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.visibility,
    required this.state,
    required this.targetAmount,
    required this.endsAtUtc,
    this.launchedAtUtc,
    required this.borrowingEnabled,
    this.suggestedContributionAmount,
    required this.createdUtc,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    visibility,
    state,
    targetAmount,
    endsAtUtc,
    launchedAtUtc,
    borrowingEnabled,
    suggestedContributionAmount,
    createdUtc,
  ];
}
