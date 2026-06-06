import 'package:equatable/equatable.dart';

import '../../../projects/domain/entities/invite_preview_entity.dart';
import 'project_invitation_join_effect.dart';

class ProjectInvitationState extends Equatable {
  final bool loading;
  final InvitePreviewEntity? preview;
  final String? errorMessage;
  final bool joining;
  final ProjectInvitationJoinEffect? joinEffect;

  const ProjectInvitationState({
    this.loading = false,
    this.preview,
    this.errorMessage,
    this.joining = false,
    this.joinEffect,
  });

  bool get canJoin =>
      preview != null && !preview!.isExpired && preview!.isJoinable && !joining;

  ProjectInvitationState copyWith({
    bool? loading,
    InvitePreviewEntity? preview,
    String? errorMessage,
    bool? joining,
    ProjectInvitationJoinEffect? joinEffect,
    bool clearError = false,
    bool clearJoinEffect = false,
  }) {
    return ProjectInvitationState(
      loading: loading ?? this.loading,
      preview: preview ?? this.preview,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      joining: joining ?? this.joining,
      joinEffect: clearJoinEffect ? null : (joinEffect ?? this.joinEffect),
    );
  }

  @override
  List<Object?> get props => [
    loading,
    preview,
    errorMessage,
    joining,
    joinEffect,
  ];
}
