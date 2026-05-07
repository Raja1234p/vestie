import 'package:equatable/equatable.dart';

abstract class VotingEvent extends Equatable {
  const VotingEvent();

  @override
  List<Object?> get props => [];
}

class SubmitVoteActionEvent extends VotingEvent {
  final String projectId;
  final bool isPositive;

  const SubmitVoteActionEvent({
    required this.projectId,
    required this.isPositive,
  });

  @override
  List<Object?> get props => [projectId, isPositive];
}
