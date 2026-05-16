import 'package:equatable/equatable.dart';

/// Row from `GET /projects/{id}` → `invites[]`.
class ProjectInviteEntity extends Equatable {
  final String id;
  final String inviteCode;
  final bool requiresApproval;
  final String expiresAtUtc;
  final int? maxUses;
  final int usedCount;

  const ProjectInviteEntity({
    required this.id,
    required this.inviteCode,
    this.requiresApproval = false,
    this.expiresAtUtc = '',
    this.maxUses,
    this.usedCount = 0,
  });

  @override
  List<Object?> get props =>
      [id, inviteCode, requiresApproval, expiresAtUtc, maxUses, usedCount];
}
