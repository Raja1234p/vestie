import 'package:equatable/equatable.dart';
import '../../domain/usecases/moderate_member_usecase.dart';

abstract class ModerationEvent extends Equatable {
  const ModerationEvent();

  @override
  List<Object?> get props => [];
}

class SubmitModerationActionEvent extends ModerationEvent {
  final String projectId;
  final String userId;
  final ModerationAction action;

  const SubmitModerationActionEvent({
    required this.projectId,
    required this.userId,
    required this.action,
  });

  @override
  List<Object?> get props => [projectId, userId, action];
}

class ResetModerationStateEvent extends ModerationEvent {
  const ResetModerationStateEvent();
}
