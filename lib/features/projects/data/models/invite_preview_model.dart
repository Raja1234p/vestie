import '../../domain/entities/invite_preview_entity.dart';

class InvitePreviewModel extends InvitePreviewEntity {
  const InvitePreviewModel({
    required super.projectId,
    required super.projectName,
    required super.projectType,
    required super.visibility,
    required super.requiresApproval,
    required super.expiresAtUtc,
    required super.isExpired,
    required super.isJoinable,
  });

  factory InvitePreviewModel.fromJson(Map<String, dynamic> json) {
    return InvitePreviewModel(
      projectId: json['projectId'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      projectType: json['projectType'] as String? ?? '',
      visibility: json['visibility'] as String? ?? '',
      requiresApproval: json['requiresApproval'] as bool? ?? false,
      expiresAtUtc: json['expiresAtUtc'] as String? ?? '',
      isExpired: json['isExpired'] as bool? ?? false,
      isJoinable: json['isJoinable'] as bool? ?? false,
    );
  }
}
