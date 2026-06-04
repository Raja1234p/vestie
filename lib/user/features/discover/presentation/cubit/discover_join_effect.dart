import 'package:equatable/equatable.dart';

/// One-shot UI effects after [DiscoverCubit.joinProject] — handled in
/// [DiscoverJoinEffectsListener].
sealed class DiscoverJoinEffect extends Equatable {
  const DiscoverJoinEffect();

  @override
  List<Object?> get props => [];
}

final class DiscoverJoinShowError extends DiscoverJoinEffect {
  final String message;
  final String? title;

  const DiscoverJoinShowError(this.message, {this.title});

  @override
  List<Object?> get props => [message, title];
}

final class DiscoverJoinShowRequestSubmitted extends DiscoverJoinEffect {
  final String projectId;
  final String projectName;
  final bool isInvestment;

  const DiscoverJoinShowRequestSubmitted({
    required this.projectId,
    required this.projectName,
    required this.isInvestment,
  });

  @override
  List<Object?> get props => [projectId, projectName, isInvestment];
}

final class DiscoverJoinOpenDetail extends DiscoverJoinEffect {
  final String projectId;
  final String projectName;
  final bool isInvestment;

  const DiscoverJoinOpenDetail({
    required this.projectId,
    required this.projectName,
    required this.isInvestment,
  });

  @override
  List<Object?> get props => [projectId, projectName, isInvestment];
}
