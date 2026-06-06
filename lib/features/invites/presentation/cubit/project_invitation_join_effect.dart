import 'package:equatable/equatable.dart';

sealed class ProjectInvitationJoinEffect extends Equatable {
  const ProjectInvitationJoinEffect();

  @override
  List<Object?> get props => [];
}

final class ProjectInvitationJoinShowError extends ProjectInvitationJoinEffect {
  final String message;
  final String? title;

  const ProjectInvitationJoinShowError(this.message, {this.title});

  @override
  List<Object?> get props => [message, title];
}

final class ProjectInvitationJoinShowRequestSubmitted
    extends ProjectInvitationJoinEffect {
  final String projectId;
  final String projectName;
  final bool isInvestment;

  const ProjectInvitationJoinShowRequestSubmitted({
    required this.projectId,
    required this.projectName,
    required this.isInvestment,
  });

  @override
  List<Object?> get props => [projectId, projectName, isInvestment];
}

final class ProjectInvitationJoinOpenDetail
    extends ProjectInvitationJoinEffect {
  final String projectId;
  final String projectName;
  final bool isInvestment;

  const ProjectInvitationJoinOpenDetail({
    required this.projectId,
    required this.projectName,
    required this.isInvestment,
  });

  @override
  List<Object?> get props => [projectId, projectName, isInvestment];
}

final class ProjectInvitationJoinNeedsAuth extends ProjectInvitationJoinEffect {
  const ProjectInvitationJoinNeedsAuth();
}
