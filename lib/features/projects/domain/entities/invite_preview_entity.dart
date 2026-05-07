import 'package:equatable/equatable.dart';

class InvitePreviewEntity extends Equatable {
  final String projectId;
  final String projectName;
  final String projectType;
  final String visibility;
  final bool requiresApproval;
  final String expiresAtUtc;
  final bool isExpired;
  final bool isJoinable;

  const InvitePreviewEntity({
    required this.projectId,
    required this.projectName,
    required this.projectType,
    required this.visibility,
    required this.requiresApproval,
    required this.expiresAtUtc,
    required this.isExpired,
    required this.isJoinable,
  });

  @override
  List<Object?> get props => [
        projectId,
        projectName,
        projectType,
        visibility,
        requiresApproval,
        expiresAtUtc,
        isExpired,
        isJoinable,
      ];
}
